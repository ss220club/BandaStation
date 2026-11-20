import { useEffect, useState } from 'react';
import {
  Box,
  Button,
  Input,
  LabeledList,
  NoticeBox,
  RestrictedInput,
  Section,
  TextArea,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { JOBS_RU } from '../bandastation/ru_jobs';
import { NtosWindow } from '../layouts';

type CrewRecord = {
  ref: string;
  name: string;
  rank: string;
};

type Data = {
  authorized: BooleanLike;
  records?: CrewRecord[];
  paper_count: number;
  max_fine: number;
  article_limit: number;
  details_limit: number;
  program_uid: number;
  submission_number: number;
  handled_submission: number | null;
  feedback: string | null;
};

function recordLabel(record: CrewRecord) {
  return `${record.name} (${JOBS_RU[record.rank] || record.rank})`;
}

export function NtosFinesPro() {
  const { act, data } = useBackend<Data>();
  const {
    article_limit,
    authorized,
    details_limit,
    feedback,
    handled_submission,
    max_fine,
    paper_count,
    program_uid,
    records = [],
    submission_number,
  } = data;
  const [search, setSearch] = useState('');
  const [recordRef, setRecordRef] = useState('');
  const [article, setArticle] = useState('');
  const [details, setDetails] = useState('');
  const [amount, setAmount] = useState(0);
  const [pendingSubmission, setPendingSubmission] = useState<{
    program: number;
    number: number;
  }>();
  const [formError, setFormError] = useState<string>();

  useEffect(() => {
    if (pendingSubmission === undefined) {
      return;
    }
    if (!authorized || pendingSubmission.program !== program_uid) {
      setPendingSubmission(undefined);
      return;
    }
    if (submission_number <= pendingSubmission.number) {
      return;
    }
    setPendingSubmission(undefined);
    if (handled_submission !== pendingSubmission.number) {
      setFormError('ПДА обработал другую заявку. Проверьте записи СБ.');
      return;
    }
    if (feedback) {
      setFormError(feedback);
      return;
    }
    setRecordRef('');
    setArticle('');
    setDetails('');
    setAmount(0);
  }, [
    authorized,
    feedback,
    handled_submission,
    pendingSubmission,
    program_uid,
    submission_number,
  ]);

  const query = search.trim().toLowerCase();
  const visibleRecords = records.filter((record) =>
    `${recordLabel(record)} ${record.rank}`.toLowerCase().includes(query),
  );
  const selectedRecord = records.find((record) => record.ref === recordRef);
  const articleNumber = article.trim();
  const fineDetails = details.trim();
  const articleTooLong = [...articleNumber].length > article_limit;
  const detailsTooLong = [...fineDetails].length > details_limit;

  return (
    <NtosWindow width={490} height={520}>
      <NtosWindow.Content scrollable>
        {!authorized ? (
          <NoticeBox danger>Вставьте в ПДА ID-карту с доступом СБ.</NoticeBox>
        ) : (
          <>
            {!paper_count && (
              <NoticeBox danger>Заправьте ПДА бумагой для печати.</NoticeBox>
            )}
            {!recordRef ? (
              <Section title="Экипаж">
                <Input
                  fluid
                  onChange={setSearch}
                  placeholder="Поиск по имени или должности"
                  value={search}
                />
                <Section height={300} scrollable>
                  {visibleRecords.length ? (
                    visibleRecords.map((record) => (
                      <Button
                        key={record.ref}
                        fluid
                        style={{
                          whiteSpace: 'normal',
                          overflowWrap: 'anywhere',
                        }}
                        onClick={() => {
                          setRecordRef(record.ref);
                          setArticle('');
                          setDetails('');
                          setAmount(0);
                          setFormError(undefined);
                        }}
                      >
                        {recordLabel(record)}
                      </Button>
                    ))
                  ) : (
                    <NoticeBox>Записи не найдены.</NoticeBox>
                  )}
                </Section>
              </Section>
            ) : (
              <Section
                title="Новый штраф"
                buttons={
                  <Button
                    disabled={pendingSubmission !== undefined}
                    icon="arrow-left"
                    onClick={() => setRecordRef('')}
                  >
                    К списку экипажа
                  </Button>
                }
              >
                {formError && <NoticeBox danger>{formError}</NoticeBox>}
                <LabeledList>
                  <LabeledList.Item label="Получатель">
                    <Box style={{ overflowWrap: 'anywhere' }}>
                      {selectedRecord
                        ? recordLabel(selectedRecord)
                        : 'Запись удалена'}
                    </Box>
                  </LabeledList.Item>
                  <LabeledList.Item label="Номер статьи">
                    <Input fluid onChange={setArticle} value={article} />
                    {articleTooLong && (
                      <Box color="bad">Лимит символов — {article_limit}.</Box>
                    )}
                  </LabeledList.Item>
                  <LabeledList.Item label="Сумма, кр.">
                    <RestrictedInput
                      fluid
                      minValue={1}
                      maxValue={max_fine}
                      onChange={setAmount}
                      value={amount}
                    />
                  </LabeledList.Item>
                  <LabeledList.Item label="Бумага в ПДА">
                    {paper_count}
                  </LabeledList.Item>
                </LabeledList>
                <Box mt={1}>Детали</Box>
                <TextArea
                  fluid
                  height="48px"
                  onChange={setDetails}
                  value={details}
                />
                {detailsTooLong && (
                  <Box color="bad">Лимит символов — {details_limit}.</Box>
                )}
                <Button.Confirm
                  mt={1}
                  icon="print"
                  disabled={
                    pendingSubmission !== undefined ||
                    !selectedRecord ||
                    !articleNumber ||
                    articleTooLong ||
                    !fineDetails ||
                    detailsTooLong ||
                    !Number.isInteger(amount) ||
                    amount < 1 ||
                    amount > max_fine ||
                    !paper_count
                  }
                  confirmContent="Подтвердить штраф"
                  onClick={() => {
                    setFormError(undefined);
                    setPendingSubmission({
                      program: program_uid,
                      number: submission_number,
                    });
                    act('issue_fine', {
                      record_ref: recordRef,
                      article: articleNumber,
                      details: fineDetails,
                      amount,
                      program_uid,
                      submission_number,
                    });
                  }}
                >
                  Выписать и напечатать
                </Button.Confirm>
              </Section>
            )}
          </>
        )}
      </NtosWindow.Content>
    </NtosWindow>
  );
}
