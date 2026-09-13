import { promises as fs } from 'node:fs';
import MWBot from 'mwbot';

const { USERNAME, PASSWORD } = process.env;

if (!USERNAME) {
  console.error('USERNAME was not set.');
  process.exit(1);
}

if (!PASSWORD) {
  console.error('PASSWORD was not set.');
  process.exit(1);
}

const PAGE_EDIT_FILENAME = process.argv[2];

if (!PAGE_EDIT_FILENAME) {
  console.error('No filename specified to edit pages');
  process.exit(1);
}

const FILE_EDIT_FILENAME = process.argv[3];

if (!FILE_EDIT_FILENAME) {
  console.error('No filename specified to edit files');
  process.exit(1);
}

const MAX_RATE_LIMIT_RETRIES = 5;
const RATE_LIMIT_RETRY_DELAY = 5000;

const sleep = (delay) => new Promise((resolve) => setTimeout(resolve, delay));

async function withRateLimitRetry(operation, description, refreshToken) {
  let tokenRefreshes = 0;

  for (let attempt = 0; ; attempt++) {
    try {
      return await operation();
    } catch (error) {
      if (error.code === 'badtoken' && refreshToken && tokenRefreshes === 0) {
        tokenRefreshes++;
        console.log(`${description} received an invalid token; logging in again`);
        await withRateLimitRetry(refreshToken, 'Refreshing login');
        continue;
      }

      if (error.code !== 'ratelimited' || attempt >= MAX_RATE_LIMIT_RETRIES) {
        throw error;
      }

      const delay = RATE_LIMIT_RETRY_DELAY * 2 ** attempt;
      console.log(
        `${description} was rate limited; retrying in ${delay / 1000}s ` +
          `(${attempt + 1}/${MAX_RATE_LIMIT_RETRIES})`,
      );
      await sleep(delay);
    }
  }
}

async function main() {
  console.log(`Reading from ${PAGE_EDIT_FILENAME}`);
  const editFile = await (await fs.readFile(PAGE_EDIT_FILENAME, 'utf8')).split(
    '\n',
  );

  console.log(`Logging in as ${USERNAME}`);

  const bot = new MWBot();
  const login = () => {
    bot.editToken = false;
    return bot.loginGetEditToken({
      apiUrl: 'https://bs.ss220.club//api.php',
      username: USERNAME,
      password: PASSWORD,
    });
  };

  await withRateLimitRetry(login, 'Logging in');

  console.log('Logged in');

  // This is not Promise.all as to not flood with a bunch of traffic at once
  for (const editLine of editFile) {
    if (editLine.length === 0) {
      continue;
    }

    let { title, text } = JSON.parse(editLine);
    text =
      '<noinclude><b>This page is automated by Autowiki. Do NOT edit it manually.</b></noinclude>' +
      text;

    console.log(`Editing ${title}...`);
    await withRateLimitRetry(
      () => bot.edit(title, text, `Autowiki edit @ ${new Date().toISOString()}`),
      `Editing ${title}`,
      login,
    );
  }

  // Same here
  for (const asset of await fs.readdir(FILE_EDIT_FILENAME)) {
    const assetPath = `${FILE_EDIT_FILENAME}/${asset}`;
    const assetName = `Autowiki-${asset}`;

    console.log(`Replacing ${assetName}...`);
    await withRateLimitRetry(
      () =>
        bot.upload(
          assetName,
          assetPath,
          `Autowiki upload @ ${new Date().toISOString()}`,
        ),
      `Replacing ${assetName}`,
      login,
    ).catch((error) => {
        if (error.code === 'fileexists-no-change') {
          console.log(`${assetName} is an exact duplicate`);
        } else {
          return Promise.reject(error);
        }
      });
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
