import { useState } from 'react';
import { Box, Icon, Tooltip } from 'tgui-core/components';

import { useBackend } from '../../../../backend';
import type { BodyModification, PreferencesMenuData } from '../../types';
import {
  CATEGORY_CONFIG,
  DEFAULT_CATEGORY_CONFIG,
  MANUFACTURER_DESCRIPTIONS,
  getManufacturerColor,
} from './constants';

type ModificationCardProps = {
  modification: BodyModification;
  isInstalled: boolean;
  isIncompatible: boolean;
  isSelected: boolean;
  isDropdownOpen: boolean;
  onSetDropdownOpen: (open: boolean) => void;
  onAdd: () => void;
  onRemove: () => void;
  onSelect: () => void;
};

export function ModificationCard(props: ModificationCardProps) {
  const {
    modification,
    isInstalled,
    isIncompatible,
    isSelected,
    isDropdownOpen,
    onSetDropdownOpen,
    onAdd,
    onRemove,
    onSelect,
  } = props;
  const { act, data } = useBackend<PreferencesMenuData>();
  const [isHovered, setIsHovered] = useState(false);

  const manufacturers = data.manufacturers?.[modification.key] || null;
  const selectedManufacturer =
    data.selected_manufacturer?.[modification.key] ||
    (manufacturers ? manufacturers[0] : null);

  const categoryConfig =
    CATEGORY_CONFIG[modification.category] || DEFAULT_CATEGORY_CONFIG;

  let borderColor = 'rgba(255,42,109,0.3)';
  let bgGradient =
    'linear-gradient(135deg, rgba(26,26,36,0.9) 0%, rgba(10,10,18,0.95) 100%)';

  if (isInstalled) {
    borderColor = '#39ff14';
    bgGradient =
      'linear-gradient(135deg, rgba(57,255,20,0.1) 0%, rgba(10,10,18,0.95) 100%)';
  } else if (isIncompatible) {
    borderColor = 'rgba(255,51,51,0.3)';
  }

  return (
    <div
      onMouseEnter={() => setIsHovered(true)}
      onMouseLeave={() => setIsHovered(false)}
    >
      <Box
        style={{
          background: bgGradient,
          border: `1px solid ${borderColor}`,
          borderRadius: '4px',
          marginBottom: '0.5rem',
          cursor: 'pointer',
          position: 'relative',
          zIndex: isDropdownOpen ? 2100 : 1,
          opacity: isIncompatible ? 0.5 : 1,
          transform:
            isHovered && !isIncompatible
              ? 'translateY(-1px) scale(1.008)'
              : 'none',
          boxShadow: isSelected
            ? isInstalled
              ? '0 0 0 1px rgba(57,255,20,0.45), 0 8px 24px rgba(57,255,20,0.16)'
              : '0 0 0 1px rgba(255,42,109,0.45), 0 8px 24px rgba(255,42,109,0.18)'
            : isHovered && !isIncompatible
              ? '0 6px 18px rgba(0,0,0,0.35)'
              : 'none',
          transition:
            'transform 0.16s ease, box-shadow 0.22s ease, border-color 0.2s ease, opacity 0.2s ease',
        }}
        onClick={() => {
          act('play_click_sound');
          onSelect();
        }}
      >
        {isInstalled && (
          <Box
            style={{
              position: 'absolute',
              top: 0,
              left: 0,
              width: '4px',
              height: '100%',
              background: '#39ff14',
              boxShadow: '0 0 10px #39ff14',
            }}
          />
        )}

        <Box
          style={{
            display: 'flex',
            alignItems: 'flex-start',
            padding: '0.6rem 0.75rem',
            gap: '0.6rem',
          }}
        >
          <Box
            style={{
              width: '32px',
              height: '32px',
              minWidth: '32px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              background: `rgba(${isInstalled ? '57,255,20' : '255,42,109'},0.15)`,
              border: `2px solid ${isInstalled ? '#39ff14' : categoryConfig.color}`,
              borderRadius: '4px',
              fontSize: '0.95rem',
              color: isInstalled ? '#39ff14' : categoryConfig.color,
              transform:
                isHovered && !isIncompatible ? 'scale(1.06) rotate(-2deg)' : 'none',
              transition: 'transform 0.16s ease, border-color 0.2s ease',
            }}
          >
            <Icon name={categoryConfig.icon} />
          </Box>

          <Box style={{ flex: 1, minWidth: 0 }}>
            <Box
              style={{
                fontSize: '0.85rem',
                fontWeight: 600,
                color: '#e0e0e0',
                lineHeight: 1.3,
                marginBottom: '0.2rem',
              }}
            >
              {modification.name}
            </Box>
            <Box
              style={{
                fontSize: '0.7rem',
                color: '#8a8a9a',
                textTransform: 'uppercase',
                letterSpacing: '0.5px',
              }}
            >
              {modification.category}
            </Box>
          </Box>

          <Box
            style={{
              display: 'flex',
              flexDirection: 'column',
              gap: '0.3rem',
              alignItems: 'flex-end',
            }}
            onClick={(e) => e.stopPropagation()}
          >
            {Array.isArray(manufacturers) && isInstalled && (
              <Box style={{ position: 'relative', zIndex: isDropdownOpen ? 2200 : 1 }}>
                <Box
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: '0.4rem',
                    padding: '0.35rem 0.6rem',
                    background: isDropdownOpen
                      ? 'rgba(0,240,255,0.2)'
                      : 'rgba(0,240,255,0.1)',
                    border: isDropdownOpen
                      ? '1px solid rgba(0,240,255,0.7)'
                      : '1px solid rgba(0,240,255,0.4)',
                    borderRadius: isDropdownOpen ? '3px 3px 0 0' : '3px',
                    cursor: 'pointer',
                    fontSize: '0.8rem',
                    fontWeight: 600,
                    color: '#00f0ff',
                    minWidth: '130px',
                    justifyContent: 'space-between',
                    borderLeft: `3px solid ${getManufacturerColor(selectedManufacturer || 'general')}`,
                  }}
                  onClick={() => {
                    act('play_click_sound');
                    onSetDropdownOpen(!isDropdownOpen);
                  }}
                >
                  <Box
                    style={{
                      width: '8px',
                      height: '8px',
                      borderRadius: '50%',
                      background: getManufacturerColor(
                        selectedManufacturer || 'general',
                      ),
                      boxShadow: `0 0 4px ${getManufacturerColor(selectedManufacturer || 'general')}`,
                      flexShrink: 0,
                    }}
                  />
                  <span style={{ flex: 1 }}>
                    {selectedManufacturer === 'None'
                      ? 'Без протеза'
                      : selectedManufacturer}
                  </span>
                  <Icon name={isDropdownOpen ? 'chevron-up' : 'chevron-down'} />
                </Box>
                {isDropdownOpen && (
                  <Box
                    style={{
                      position: 'absolute',
                      top: '100%',
                      right: 0,
                      left: 0,
                      background:
                        'linear-gradient(180deg, rgba(10,10,18,0.98) 0%, rgba(26,26,36,0.98) 100%)',
                      border: '1px solid rgba(0,240,255,0.7)',
                      borderTop: 'none',
                      borderRadius: '0 0 4px 4px',
                      overflow: 'hidden',
                      zIndex: 2300,
                      boxShadow: '0 4px 20px rgba(0,0,0,0.5)',
                      maxHeight: '200px',
                      overflowY: 'auto',
                    }}
                  >
                    {manufacturers.map((brand: string) => {
                      const isSelectedBrand = brand === selectedManufacturer;
                      const brandColor = getManufacturerColor(brand);
                      const brandDesc =
                        MANUFACTURER_DESCRIPTIONS[brand.toLowerCase()];
                      return (
                        <Tooltip
                          key={brand}
                          content={
                            brandDesc ? (
                              <Box style={{ maxWidth: '200px' }}>
                                <Box
                                  bold
                                  style={{
                                    color: brandColor,
                                    marginBottom: '0.25rem',
                                    fontSize: '0.85rem',
                                  }}
                                >
                                  {brand === 'None' ? 'Без протеза' : brand}
                                </Box>
                                <Box style={{ fontSize: '0.78rem', color: '#ccc' }}>
                                  {brandDesc}
                                </Box>
                              </Box>
                            ) : brand === 'None' ? (
                              'Без протеза'
                            ) : (
                              brand
                            )
                          }
                          position="left"
                        >
                          <Box
                            style={{
                              padding: '0.5rem 0.75rem',
                              fontSize: '0.8rem',
                              color: isSelectedBrand ? '#00f0ff' : '#e0e0e0',
                              background: isSelectedBrand
                                ? 'rgba(0,240,255,0.15)'
                                : 'transparent',
                              cursor: 'pointer',
                              display: 'flex',
                              alignItems: 'center',
                              gap: '0.5rem',
                              borderLeft: `3px solid ${brandColor}`,
                            }}
                            onClick={() => {
                              act('play_install_sound');
                              act('set_body_modification_manufacturer', {
                                body_modification_key: modification.key,
                                manufacturer: brand,
                              });
                              onSetDropdownOpen(false);
                            }}
                          >
                            <Box
                              style={{
                                width: '8px',
                                height: '8px',
                                borderRadius: '50%',
                                background: brandColor,
                                boxShadow: `0 0 4px ${brandColor}`,
                                flexShrink: 0,
                              }}
                            />
                            <span style={{ flex: 1 }}>
                              {brand === 'None' ? 'Без протеза' : brand}
                            </span>
                            {isSelectedBrand && (
                              <Icon
                                name="check"
                                style={{ color: '#00f0ff', fontSize: '0.75rem' }}
                              />
                            )}
                          </Box>
                        </Tooltip>
                      );
                    })}
                  </Box>
                )}
              </Box>
            )}

            {isInstalled ? (
              <Box
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: '0.4rem',
                  padding: '0.35rem 0.6rem',
                  background: 'rgba(255,51,51,0.2)',
                  border: '1px solid rgba(255,51,51,0.5)',
                  borderRadius: '3px',
                  cursor: 'pointer',
                  fontSize: '0.75rem',
                  fontWeight: 600,
                  color: '#ff3333',
                  textTransform: 'uppercase',
                  letterSpacing: '0.5px',
                  whiteSpace: 'nowrap',
                }}
                onClick={() => {
                  act('play_deselect_sound');
                  onRemove();
                }}
              >
                <Icon name="times" /> Удалить
              </Box>
            ) : (
              <Tooltip
                content={
                  isIncompatible
                    ? 'Несовместимо с уже установленными модификациями'
                    : ''
                }
              >
                <Box
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: '0.4rem',
                    padding: '0.35rem 0.6rem',
                    background: isIncompatible
                      ? 'rgba(100,100,100,0.2)'
                      : 'rgba(57,255,20,0.15)',
                    border: isIncompatible
                      ? '1px solid rgba(100,100,100,0.3)'
                      : '1px solid rgba(57,255,20,0.5)',
                    borderRadius: '3px',
                    cursor: isIncompatible ? 'not-allowed' : 'pointer',
                    fontSize: '0.75rem',
                    fontWeight: 600,
                    color: isIncompatible ? '#666' : '#39ff14',
                    textTransform: 'uppercase',
                    letterSpacing: '0.5px',
                    whiteSpace: 'nowrap',
                  }}
                  onClick={
                    isIncompatible
                      ? undefined
                      : () => {
                          act('play_install_sound');
                          onAdd();
                        }
                  }
                >
                  <Icon name="plus" /> Установить
                </Box>
              </Tooltip>
            )}
          </Box>
        </Box>
      </Box>
    </div>
  );
}
