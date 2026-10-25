// Compile with the .NET Framework compiler and /platform:x86.
// This host never pins the tested DLL and never calls an unmapped function.
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.Runtime.InteropServices;
using System.Security.Cryptography;
using System.Text;

internal static class ModuleLifetimeProbe
{
    private const uint FromAddress = 4;
    private const uint UnchangedRefcount = 2;
    private const int ModuleNotFound = 126;

    [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true, ExactSpelling = true)]
    private static extern IntPtr LoadLibraryW(string path);
    [DllImport("kernel32.dll", CharSet = CharSet.Ansi, SetLastError = true, ExactSpelling = true)]
    private static extern IntPtr GetProcAddress(IntPtr module, string name);
    [DllImport("kernel32.dll", SetLastError = true, ExactSpelling = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool FreeLibrary(IntPtr module);
    [DllImport("kernel32.dll", SetLastError = true, ExactSpelling = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool GetModuleHandleExW(uint flags, IntPtr address, out IntPtr module);

    [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
    private delegate IntPtr ByondFunction(int argc, IntPtr argv);

    private static string Call(ByondFunction function, string argument)
    {
        IntPtr argumentPointer = IntPtr.Zero;
        IntPtr arguments = IntPtr.Zero;
        try
        {
            if (argument != null)
            {
                argumentPointer = Marshal.StringToHGlobalAnsi(argument);
                arguments = Marshal.AllocHGlobal(IntPtr.Size);
                Marshal.WriteIntPtr(arguments, argumentPointer);
            }
            string value = Marshal.PtrToStringAnsi(function(argument == null ? 0 : 1, arguments));
            if (String.IsNullOrEmpty(value) || value.StartsWith("RUST_G_ERROR", StringComparison.Ordinal))
                throw new InvalidOperationException("The native export returned no value or a lifetime-guard error: " + value);
            return value;
        }
        finally
        {
            if (arguments != IntPtr.Zero) Marshal.FreeHGlobal(arguments);
            if (argumentPointer != IntPtr.Zero) Marshal.FreeHGlobal(argumentPointer);
        }
    }

    private static string Quote(string value)
    {
        if (value == null) return "null";
        StringBuilder result = new StringBuilder("\"");
        foreach (char character in value)
        {
            if (character == '"' || character == '\\') result.Append('\\').Append(character);
            else if (character < 32) result.Append("\\u").Append(((int)character).ToString("x4"));
            else result.Append(character);
        }
        return result.Append('"').ToString();
    }

    private static string Json(Dictionary<string, object> fields)
    {
        List<string> pairs = new List<string>();
        foreach (KeyValuePair<string, object> field in fields)
        {
            string value = field.Value == null ? "null" : field.Value is string ? Quote((string)field.Value)
                : field.Value is bool ? ((bool)field.Value ? "true" : "false")
                : Convert.ToString(field.Value, CultureInfo.InvariantCulture);
            pairs.Add(Quote(field.Key) + ":" + value);
        }
        return "{" + String.Join(",", pairs.ToArray()) + "}";
    }

    private static int Main(string[] args)
    {
        if (args.Length != 4)
        {
            Console.Error.WriteLine("Usage: ModuleLifetimeProbe DLL Pinned|Unloaded get_version|file_exists report.json");
            return 2;
        }
        Dictionary<string, object> report = new Dictionary<string, object>();
        IntPtr ownedModule = IntPtr.Zero;
        int exitCode = 1;
        try
        {
            if (IntPtr.Size != 4) throw new InvalidOperationException("The probe must run as a 32-bit process.");
            bool expectedPinned = args[1] == "Pinned";
            if (!expectedPinned && args[1] != "Unloaded") throw new ArgumentException("Invalid expected module state.");
            if (args[2] != "get_version" && args[2] != "file_exists") throw new ArgumentException("Invalid first export.");
            string library = Path.GetFullPath(args[0]);
            report["libraryPath"] = library;
            report["expectedState"] = args[1];
            report["firstExport"] = args[2];
            report["processBits"] = IntPtr.Size * 8;
            using (Process process = Process.GetCurrentProcess()) report["processId"] = process.Id;
            using (SHA256 hash = SHA256.Create())
            using (FileStream input = File.OpenRead(library))
                report["sha256"] = BitConverter.ToString(hash.ComputeHash(input)).Replace("-", "").ToLowerInvariant();
            ownedModule = LoadLibraryW(library);
            if (ownedModule == IntPtr.Zero) throw new Win32Exception(Marshal.GetLastWin32Error(), "LoadLibraryW failed.");
            IntPtr originalModule = ownedModule;
            IntPtr address = GetProcAddress(ownedModule, args[2]);
            if (address == IntPtr.Zero) throw new Win32Exception(Marshal.GetLastWin32Error(), "The native export was not found.");
            ByondFunction function = (ByondFunction)Marshal.GetDelegateForFunctionPointer(address, typeof(ByondFunction));
            IntPtr queriedModule;
            bool loadedBefore = GetModuleHandleExW(FromAddress | UnchangedRefcount, address, out queriedModule);
            report["loadedBefore"] = loadedBefore;
            if (!loadedBefore || queriedModule != originalModule) throw new InvalidOperationException("Initial module-address lookup failed.");
            const string probeFile = "lifetime-probe.txt";
            if (args[2] == "file_exists") File.WriteAllText(probeFile, "ASCII relative argument fixture");
            string argument = args[2] == "file_exists" ? probeFile : null;
            string before = Call(function, argument);
            report["valueBefore"] = before;
            report["versionValue"] = args[2] == "get_version" ? before : null;
            if (argument != null && before != "true") throw new InvalidOperationException("file_exists did not find the relative ASCII fixture.");
            bool freed = FreeLibrary(ownedModule);
            report["freeOk"] = freed;
            if (!freed) throw new Win32Exception(Marshal.GetLastWin32Error(), "FreeLibrary failed.");
            ownedModule = IntPtr.Zero;

            // No LoadLibrary call is allowed between FreeLibrary and this query.
            bool loadedAfter = GetModuleHandleExW(FromAddress | UnchangedRefcount, address, out queriedModule);
            int queryError = loadedAfter ? 0 : Marshal.GetLastWin32Error();
            report["loadedAfter"] = loadedAfter;
            report["queryError"] = queryError;
            if (loadedAfter != expectedPinned) throw new InvalidOperationException("The module lifetime differs from the requested expectation.");
            if (!loadedAfter && queryError != ModuleNotFound) throw new Win32Exception(queryError, "Unexpected module-address lookup error.");
            if (loadedAfter)
            {
                if (queriedModule != originalModule) throw new InvalidOperationException("A different module occupies the old export address.");
                string after = Call(function, argument); // Only reached after confirming the module is still mapped.
                report["valueAfter"] = after;
                if (after != before) throw new InvalidOperationException("The export result changed after the loader reference was released.");
                IntPtr versionAddress = GetProcAddress(queriedModule, "get_version");
                if (versionAddress == IntPtr.Zero) throw new Win32Exception(Marshal.GetLastWin32Error(), "Pinned get_version export was not found.");
                report["versionValue"] = Call((ByondFunction)Marshal.GetDelegateForFunctionPointer(versionAddress, typeof(ByondFunction)), null);
            }
            report["passed"] = true;
            exitCode = 0;
        }
        catch (Exception error)
        {
            report["passed"] = false;
            report["error"] = error.ToString();
        }
        finally
        {
            if (ownedModule != IntPtr.Zero) FreeLibrary(ownedModule);
        }
        string json = Json(report);
        File.WriteAllText(Path.GetFullPath(args[3]), json + Environment.NewLine, new UTF8Encoding(false));
        Console.WriteLine(json);
        return exitCode;
    }
}
