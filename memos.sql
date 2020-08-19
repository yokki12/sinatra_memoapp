create table memos (
  id serial primary key,
  title text,
  content text,
  created timestamp default 'now'
);
insert into memos (
  title, 
  content
)
values (
  'メモのタイトルです',
  'メモの内容をここに書いてね'
);
