file = File.open("test.txt", "w")

begin
  10000000.times {|i| file.puts(format('%016d', i)); sleep 0.01 }
ensure
  file.close
end

# `file.puts(format('%08d', i))`実行時に`tail -f test.txt`をしたときに定期的に追記された末尾
# 00000910
# 00001821
# 00002732
#
# `file.puts(format('%016d', i))`実行時
# 0000000000000481
# 0000000000000963
# 0000000000001445
# 0000000000001927
# 0000000000002409
#
# file.closeをせずとも定期的に追記されているので、いい感じのタイミングでflushされるといえる
# しかも毎回同じ結果だったことから法則性も見えそうで、8KB(8000字)くらいで自動flushすると推測