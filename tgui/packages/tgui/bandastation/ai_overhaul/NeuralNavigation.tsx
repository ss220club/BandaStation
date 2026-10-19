import { Icon } from 'tgui-core/components';

type Destination = { id: string; label: string; icon: string; count?: number };

export function NeuralNavigation({
  items,
  selected,
  onSelect,
}: {
  items: Destination[];
  selected: string;
  onSelect: (id: string) => void;
}) {
  return (
    <nav className="AiOS__firmwareNav" aria-label="Разделы приложения">
      {items.map((item, index) => (
        <button
          type="button"
          key={item.id}
          className={`Button Button--color--transparent${selected === item.id ? ' Button--selected' : ''}`}
          aria-current={selected === item.id ? 'page' : undefined}
          onClick={() => onSelect(item.id)}
        >
          <span className="Button__content">
            <span className="AiOS__navIndex">
              {String(index + 1).padStart(2, '0')}
            </span>
            <Icon name={item.icon} />
            <span className="AiOS__navLabel">{item.label}</span>
            {item.count !== undefined && (
              <span className="AiOS__navCaption">{item.count}</span>
            )}
          </span>
        </button>
      ))}
    </nav>
  );
}
