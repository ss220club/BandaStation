"""Offline RustG PE32/API audit; no DLL is loaded. Layout: Microsoft PE Format."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import struct

class PE:
    def __init__(self, path):
        self.path, self.data = Path(path).resolve(), Path(path).read_bytes()
        self.u = lambda fmt, at: struct.unpack_from('<' + fmt, self.data, at)
        pe = self.u('I', 0x3c)[0]
        if self.data[:2] != b'MZ' or self.data[pe:pe + 4] != b'PE\0\0':
            raise ValueError('Not a PE image: ' + str(path))
        self.machine, count = self.u('HH', pe + 4)
        optional, flags = self.u('HH', pe + 20)
        self.magic, self.is_dll = self.u('H', pe + 24)[0], bool(flags & 0x2000)
        if self.magic != 0x10b or self.machine != 0x14c or not self.is_dll:
            raise ValueError('Expected an i386 PE32 DLL: ' + str(path))
        self.directories = [self.u('II', pe + 24 + 96 + i * 8) for i in range(16)]
        self.sections = [self.u('4I', pe + 24 + optional + i * 40 + 8) for i in range(count)]
    def at(self, rva):
        for virtual_size, start, raw_size, raw_at in self.sections:
            if start <= rva < start + max(virtual_size, raw_size):
                return raw_at + rva - start
        raise ValueError('Unmapped RVA: ' + hex(rva))
    def text(self, rva):
        at = self.at(rva)
        return self.data[at:self.data.index(b'\0', at)].decode('ascii')
    def exports(self):
        directory = self.at(self.directories[0][0])
        functions, count, addresses, names, ordinals = self.u('5I', directory + 20)
        result = set()
        for index in range(count):
            ordinal = self.u('H', self.at(ordinals) + index * 2)[0]
            if ordinal >= functions or not self.u('I', self.at(addresses) + ordinal * 4)[0]:
                raise ValueError('Export has no address')
            result.add(self.text(self.u('I', self.at(names) + index * 4)[0]))
        return result
    def imports(self):
        result, at = {}, self.at(self.directories[1][0])
        while any(self.u('5I', at)):
            lookup, _, _, name, address = self.u('5I', at)
            entries, thunk = [], self.at(lookup or address)
            while self.u('I', thunk)[0]:
                value = self.u('I', thunk)[0]
                entries.append('#' + str(value & 0xffff) if value & 0x80000000 else self.text(value + 2))
                thunk += 4
            result[self.text(name).lower()] = entries
            at += 20
        return result
    def metadata(self):
        return dict(path=str(self.path), sha256=hashlib.sha256(self.data).hexdigest(),
                    machine=hex(self.machine), magic=hex(self.magic), is_dll=self.is_dll)

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('baseline'); parser.add_argument('candidate'); parser.add_argument('--out', type=Path)
args = parser.parse_args()
old, new = PE(args.baseline), PE(args.candidate)
old_exports, new_exports = old.exports(), new.exports()
api = Path(__file__).resolve().parents[2] / 'code/__DEFINES/rust_g.dm'
required = set(re.findall(r'RUSTG_CALL\(\s*RUST_G\s*,\s*"([^"]+)"', api.read_text(encoding='utf-8')))
old_imports, new_imports = old.imports(), new.imports()
system = Path(os.environ.get('WINDIR', 'C:/Windows')) / 'SysWOW64'
unknown = [name for name in new_imports if not name.startswith(('api-ms-win-', 'ext-ms-win-')) and not (system / name).is_file()]
report = dict(baseline=old.metadata(), candidate=new.metadata(), baseline_exports=len(old_exports),
              candidate_exports=len(new_exports), required_api=len(required), missing_old=sorted(old_exports-new_exports),
              baseline_missing_required=sorted(required-old_exports), candidate_missing_required=sorted(required-new_exports),
              newly_missing_required=sorted((required & old_exports)-new_exports), added_exports=sorted(new_exports-old_exports),
              imports=sorted(new_imports), added_imports=sorted(new_imports.keys()-old_imports.keys()),
              imports_get_module_handle_ex_w=any('GetModuleHandleExW' in names for names in new_imports.values()),
              non_system_imports=unknown if os.name == 'nt' else None)
report['passed'] = not report['missing_old'] and not report['newly_missing_required'] and (os.name != 'nt' or not unknown)
if args.out: args.out.write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
print(json.dumps(report, indent=2)); raise SystemExit(0 if report['passed'] else 1)
