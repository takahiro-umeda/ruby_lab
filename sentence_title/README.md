# 必要なこと
- 実行環境にMeCabが入っていること
- `path/to/ruby_lab/sentence_title`で`bundle install`

# 実行方法
`ruby evaluate_titles.rb input/(タイトルファイル.txt) output/(出力ファイル.csv)`
```bash
# 例
$ ruby evaluate_titles.rb input/sample_titles.txt output/title_status.csv
2020-03-24 12:52:04 +0900: read start input/sample_titles.txt
2020-03-24 12:52:04 +0900: read end input/sample_titles.txt

$ head output/title_status.csv
title,end_with_noun?,with_space?,only_one_noun?,with_descriptive_noun?,with_particle?,with_relative?,words
crow,1,0,1,0,0,0,
うさぎと猫,1,0,0,1,1,0,
お正月の花,1,0,0,1,1,0,

# タイトル評価結果から、条件に一致するタイトルを抜き出す(今回は名詞で終わり助詞を含むタイトル)
$ cd output
# 第２引数に条件を入れる。CSVのカラム名から?を取った名前が変数名になるので、それを使った条件条件文を書く
$ ruby scripts/extract_condition_match_title_sentenses.rb title_status.csv "end_with_noun && with_particle"
2020-03-24 13:01:39 +0900: read start title_status.csv
2020-03-24 13:01:39 +0900: read end title_status.csv
# 入力ファイル名と条件がファイル名となった結果ファイルが出力される
$ head hoge_extracting_end_with_noun_\&\&_with_particle.csv
title,end_with_noun?,with_space?,only_one_noun?,with_descriptive_noun?,with_particle?,with_relative?,words
うさぎと猫,1,0,0,1,1,0,
お正月の花,1,0,0,1,1,0,
ふるいにかける水彩イラスト,1,0,0,1,1,1,
カゴに入ったたくさんの新鮮な卵,1,0,0,1,1,1,

```



