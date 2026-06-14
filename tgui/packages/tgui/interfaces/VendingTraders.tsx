import { useState } from 'react';
import {
  Box,
  Button,
  Icon,
  ImageButton,
  Input,
  NoticeBox,
  Section,
  Stack,
  ProgressBar,
} from 'tgui-core/components';
import { capitalizeAll, createSearch } from 'tgui-core/string';

import { useBackend } from '../backend';
import { JOBS_RU } from '../bandastation/ru_jobs';
import { Window } from '../layouts';
import { getLayoutState, LAYOUT, LayoutToggle } from './common/LayoutToggle';

type StockItem = {
  amount: number;
  free: boolean;
  locked?: boolean;
};

type ProductRecord = {
  path: string;
  name: string;
  price: number;
  ref: string;
  category: string;
  colorable: boolean;
  premium: boolean;
  image?: string;
  icon?: string;
  icon_state?: string;
};

type UserData = {
  name: string;
  cash: number;
  job: string;
  department: string;
};

type Category = {
  icon: string;
};

type VendingData = {
  all_products_free: boolean;
  ad: string;
  department: string;
  jobDiscount: number;
  displayed_currency_icon: string;
  displayed_currency_name: string;
  product_records: ProductRecord[];
  coin_records: ProductRecord[];
  hidden_records: ProductRecord[];
  user: UserData;
  stock: Record<string, StockItem>[];
  extended_inventory: boolean;
  access: boolean;
  categories: Record<string, Category>;
  loyalty?: Record<string, {
  locked: boolean;
  required: number;
  vendor_name?: string;
  vendor_desc?: string;
  vendor_portrait?: string;
  vendor_message?: string;
  }>;
};

export const VendingTraders = () => {
  const { act, data } = useBackend<VendingData>();

  const {
    all_products_free,
    ad,
    product_records = [],
    coin_records = [],
    hidden_records = [],
    categories,
    vendor_name,
    vendor_desc,
    vendor_portrait,
    vendor_message,
  } = data;

  const [selectedCategory, setSelectedCategory] = useState(
    Object.keys(categories)[0],
  );

  const loyaltyNames = {
    1: 'Незнакомец (LVL 1)',
    2: 'Знакомый (LVL 2)',
    3: 'Партнёр (LVL 3)',
    4: 'Доверенное лицо (LVL ELITE)',
  };

  const relationTooltip = (
    <>
      <Box mb={1}>
        Уровень лояльности: {loyaltyNames[data.trader_level]}
      </Box>

      <Box mb={1}>
       Репутация
        <ProgressBar
          value={data.trader_rep}
          maxValue={data.trader_next_rep}
        />
       {data.trader_rep}/{data.trader_next_rep}
     </Box>

     <Box>
       Прогресс продаж
       <ProgressBar
          value={data.trader_sales_progress}
          maxValue={100}
        />
        {data.trader_sales_progress}/100
      </Box>
    </>
  );

  const [stockSearch, setStockSearch] = useState('');
  const stockSearchFn = createSearch(
    stockSearch,
    (item: ProductRecord) => item.name,
  );

  let inventory: ProductRecord[] = [...product_records, ...coin_records];
  if (data.extended_inventory) {
    inventory = [...inventory, ...hidden_records];
  }

  // Just in case we still have undefined values in the list
  inventory = inventory.filter((item) => !!item);

  if (stockSearch.length >= 2) {
    inventory = inventory.filter(stockSearchFn);
  }

  const filteredCategories = Object.fromEntries(
    Object.entries(categories).filter(([categoryName]) => {
      return inventory.find((product) => {
        if ('category' in product) {
          return product.category === categoryName;
        } else {
          return false;
        }
      });
    }),
  );

  return (
    <Window width={760} height={635}>
      <Window.Content>
        <Stack fill>
          <Stack.Item width="220px">
            <Stack fill vertical>

            <Stack.Item>
              <Section title={data.vendor_name}>
                <Box
                  width="192px"
                  height="192px"
                >
                  <ImageButton
                    fluid
                    base64={data.vendor_portrait}
                    imageSize={192}
                    tooltip={data.vendor_desc}
                  />
                </Box>
              </Section>
            </Stack.Item>

            <Stack.Item grow>
              <Section title="Сообщение">
                {data.vendor_message}
              </Section>
            </Stack.Item>

            <Stack.Item>
              <Button
                fluid
                icon="clipboard-list"
                tooltip={"Получить задание у торговца. ПРИМЕЧАНИЕ: Задания выполняются в цепочке. Нельзя получить следующее задание, не выполнив предыдущее. Можно брать задания одновременно у всех торговцев."}
                onClick={() => act('take_quest')}
              >
               Получить задание
              </Button>
             </Stack.Item>

            <Stack.Item>
              <Button
                fluid
                icon="coins"
                tooltip={"Продать все предметы, подходящие для продажи торговцу. ПРИМЕЧАНИЕ: Продаются только предметы, находящиеся в рюкзаке."}
                onClick={() => act('sell_all')}
              >
               Продать всё
              </Button>
            </Stack.Item>

            <Stack.Item>
             <Button
              fluid
              icon="handshake"
              tooltip={relationTooltip}
              >
                Отношения
              </Button>
            </Stack.Item>

          </Stack>
        </Stack.Item>

        <Stack.Item grow>
          <Stack fill vertical>

          {!all_products_free && (
            <Stack.Item>
              <UserDetails />
            </Stack.Item>
          )}
          {ad && (
            <Stack.Item>
              <AdSection AdDisplay={ad} />
            </Stack.Item>
          )}
          <Stack.Item grow>
            <ProductDisplay
              inventory={inventory}
              stockSearch={stockSearch}
              setStockSearch={setStockSearch}
              selectedCategory={selectedCategory}
            />
          </Stack.Item>

          {stockSearch.length < 2 &&
            Object.keys(filteredCategories).length > 1 && (
              <Stack.Item>
                <CategorySelector
                  categories={filteredCategories}
                  selectedCategory={selectedCategory!}
                  onSelect={setSelectedCategory}
                />
              </Stack.Item>
            )}
          </Stack>
         </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

/** Displays user details if an ID is present and the user is on the station */
export const UserDetails = () => {
  const { data } = useBackend<VendingData>();
  const { user } = data;

  return (
    <NoticeBox m={0} color={user && 'blue'}>
      <Stack align="center">
        <Stack.Item>
          <Icon name="id-card" size={1.5} />
        </Stack.Item>
        <Stack.Item>
          {user
            ? `${user.name || 'Unknown'} | ${JOBS_RU[user.job] || user.job || 'Без работы'}`
            : 'ID-карта не обнаружена! Обратитесь к главе персонала.'}
        </Stack.Item>
      </Stack>
    </NoticeBox>
  );
};

const AdSection = (props: { AdDisplay: string }) => {
  const { AdDisplay } = props;

  return (
    <NoticeBox m={0} color={'yellow'}>
      <Stack align="center">
        <Stack.Item>{AdDisplay}</Stack.Item>
      </Stack>
    </NoticeBox>
  );
};

/** Displays  products in a section, with user balance at top */
const ProductDisplay = (props: {
  inventory: ProductRecord[];
  stockSearch: string;
  setStockSearch: (search: string) => void;
  selectedCategory: string | null;
}) => {
  const { data } = useBackend<VendingData>();
  const { inventory, stockSearch, setStockSearch, selectedCategory } = props;
  const {
    stock,
    all_products_free,
    user,
    displayed_currency_icon,
    displayed_currency_name,
  } = data;
  const [toggleLayout, setToggleLayout] = useState(getLayoutState(LAYOUT.Grid));

  return (
    <Section
      fill
      scrollable
      title="Товары"
      buttons={
        <Stack>
          {!all_products_free && user && (
            <Stack.Item fontSize="16px" color="green">
              {user?.cash || 0}
              {displayed_currency_name}
              <Icon name={displayed_currency_icon} color="gold" />
            </Stack.Item>
          )}
          <Stack.Item>
            <Input
              onChange={setStockSearch}
              expensive
              placeholder="Поиск..."
              value={stockSearch}
            />
          </Stack.Item>
          <LayoutToggle state={toggleLayout} setState={setToggleLayout} />
        </Stack>
      }
    >
      {inventory
        .filter((product) => {
          if (!stockSearch && 'category' in product) {
            return product.category === selectedCategory;
          } else {
            return true;
          }
        })
        .map((product) => (
          <Product
            key={product.path}
            fluid={toggleLayout === LAYOUT.List}
            product={product}
            productStock={stock[product.path]}
          />
        ))}
    </Section>
  );
};

type ProductProps = {
  product: ProductRecord;
  productStock: StockItem;
  fluid: boolean;
};

/**
 * An individual listing for an item.
 */
const Product = (props: ProductProps) => {
  const { act, data } = useBackend<VendingData>();
  const { product, productStock, fluid } = props;
  const { department, jobDiscount, all_products_free, user } = data;
  const loyaltyInfo = data.loyalty?.[product.ref];
  const loyaltyLocked = loyaltyInfo?.locked ?? false;
  const requiredLoyalty = loyaltyInfo?.required;

  const colorable = !!product.colorable;
  const free = all_products_free || productStock.free || product.price === 0;
  const discount = !product.premium && department === user?.department;
  const remaining = productStock.amount;
  const redPrice = Math.round(product.price * jobDiscount);
  const disabled =
    loyaltyLocked ||
    remaining === 0;
    (!all_products_free && !user) ||
    (!free && (discount ? redPrice : product.price) > user?.cash);

  const baseProps = {
    base64: product.image,
    dmIcon: product.icon,
    dmIconState: product.icon_state,
    asset: ['vending32x32', product.path],
    disabled: disabled,
    loyaltyLocked: loyaltyLocked,
    requiredLoyalty: loyaltyInfo?.required,
    tooltipPosition: 'bottom',
    buttons: colorable && (
      <ProductColorSelect disabled={disabled} product={product} fluid={fluid} />
    ),
    product: product,
    colorable: colorable,
    remaining: remaining,
    onClick: () => {
      act('vend', {
        ref: product.ref,
        discountless: !!product.premium,
      });
    },
  };

  const priceProps = {
    discount: discount,
    free: free,
    product: product,
    redPrice: redPrice,
  };

  return fluid ? (
    <ProductList {...baseProps} {...priceProps} />
  ) : (
    <ProductGrid {...baseProps} {...priceProps} />
  );
};

const ProductGrid = (props: any) => {
  const { product, remaining, loyaltyLocked, requiredLoyalty, ...baseProps } = props;
  const { ...priceProps } = props;

  return (
    <ImageButton
      {...baseProps}
      tooltip={
        loyaltyLocked
          ? `Для покупки требуется более высокий уровень лояльности ${requiredLoyalty}`
          : capitalizeAll(product.name)
      }
      style={{
        opacity: loyaltyLocked ? 0.5 : 1,
      }}
      buttonsAlt={
        <Stack fontSize={0.8}>
          <Stack.Item grow textAlign={'left'}>
            <ProductPrice {...priceProps} />
          </Stack.Item>
          <Stack.Item color={'lightgray'}>x{remaining}</Stack.Item>
        </Stack>
      }
    >
      {capitalizeAll(product.name)}
    </ImageButton>
  );
};

const ProductList = (props: any) => {
  const { colorable, product, remaining, ...baseProps } = props;
  const { ...priceProps } = props;

  return (
    <ImageButton {...baseProps} fluid imageSize={32}>
      <Stack textAlign={'right'} align="center">
        <Stack.Item grow textAlign={'left'}>
          {capitalizeAll(product.name)}
          <br />
          {product.path}
        </Stack.Item>
        <Stack.Item
          width={3.5}
          fontSize={0.8}
          color={'rgba(255, 255, 255, 0.5)'}
        >
          {remaining} ост.
        </Stack.Item>
        <Stack.Item
          width={3.5}
          style={{ marginRight: !colorable ? '32px' : '' }}
        >
          <ProductPrice {...priceProps} />
        </Stack.Item>
      </Stack>
    </ImageButton>
  );
};

/**
 * In the case of customizable items, ie: shoes,
 * this displays a color wheel button that opens another window.
 */

type ProductColorSelectProps = {
  disabled: boolean;
  product: ProductRecord;
  fluid: boolean;
};

const ProductColorSelect = (props: ProductColorSelectProps) => {
  const { act } = useBackend<VendingData>();
  const { disabled, product, fluid } = props;

  return (
    <Button
      width={fluid ? '32px' : '20px'}
      icon={'palette'}
      color={'transparent'}
      tooltip={'Change color'}
      style={disabled ? { pointerEvents: 'none', opacity: 0.5 } : {}}
      onClick={() => act('select_colors', { ref: product.ref })}
    />
  );
};

type ProductPriceProps = {
  discount: boolean;
  free: boolean;
  product: ProductRecord;
  redPrice: number;
};

/** The main button to purchase an item. */
const ProductPrice = (props: ProductPriceProps) => {
  const { data } = useBackend<VendingData>();
  const { displayed_currency_name } = data;
  const { discount, free, product, redPrice } = props;
  let standardPrice = `${product.price}`;
  if (free) {
    standardPrice = 'Бесплатно';
  } else if (discount) {
    standardPrice = `${redPrice}`;
  }
  return (
    <Stack.Item fontSize={0.85} color={'gold'}>
      {standardPrice}
      {!free && displayed_currency_name}
    </Stack.Item>
  );
};

const CATEGORY_COLORS = {
  Контрабанда: 'red',
  Премиум: 'yellow',
};

const CategorySelector = (props: {
  categories: Record<string, Category>;
  selectedCategory: string;
  onSelect: (category: string) => void;
}) => {
  const { categories, selectedCategory, onSelect } = props;

  return (
    <Section>
      {Object.entries(categories).map(([name, category]) => (
        <Button
          key={name}
          selected={name === selectedCategory}
          color={CATEGORY_COLORS[name]}
          icon={category.icon}
          onClick={() => onSelect(name)}
        >
          {name}
        </Button>
      ))}
    </Section>
  );
};
