# Code Review Rules

- Write PR review comments in Russian.
- Review the diff against the PR's stated goal. For each finding, cite the changed line, the affected scenario, and the consequence.
- Check modpack changes and upstream edits against AGENTS.md. If an existing extension point would work, name it and explain why.
- Check the commit messages and PR description for asset credits. A credit in either place is sufficient. If details are missing, identify the asset and the missing creator, model, or source link.
- Check that the reported verification covers the changed behavior. If a material scenario is unverified, name the scenario and the check that would cover it.

### Config

- Changes under `/config` preserve the previous behavior for deployments that have not updated their config.
- If the PR changes server configuration, include a separate review comment using the format below. Group changes by file. Use one `ADD`, `CHANGE`, or `REMOVE` entry per affected setting, even if it spans several lines. Name the key or nested path. For lists and dictionaries, identify the entries to update so maintainers can preserve local values. Include a config snippet for each nontrivial value or entry in the file's actual syntax.

Мейнтейнеры, обратите внимание на изменения конфигурации сервера в этом PR.

- [ ] После мержа обновить серверный конфиг `config/example.toml`.

```text
ADD: door_rules
  [door_rules]
  delay = 3
  allowed_roles = ["engineer", "atmospheric_technician"]

CHANGE: access_overrides.engineering
  engineer = true  # добавить ключ в существующую таблицу

REMOVE: legacy_door_mode
```
