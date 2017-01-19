# clock_quiz
clock quiz generator for niko

---

* ruby 2.3 必須

* Windowsで、clock_quiz_setting.yaml を、 ClockQuiz.bat にdragすると、clock_quiz_setting.yaml の設定にしたがって、ファイル作成。

* 設定yamlの内容

| 項目 | 型 | 内容 |
|:-----------|:------------|:------------|
|quiz_count|number(int)|問題の数|
|quiz_sort|bool|問題を答え順でソートするかどうか|
|selection_count|number(int)|選択肢の数|
|selection_sort|bool|選択肢をソートするかどうか|
|min_hour|number(int)|最小時刻(0..23)|
|max_hour|number(int)|最大時刻(0..23)|
|minute_unit|number(int)|分区切り(1 < n)|
|answer_ok_color|string(web color)|正答選択時の背景色|
|file_path_proc|string(ruby lambda)|出力ファイルパスを返すrubyのProcコード文字列|
