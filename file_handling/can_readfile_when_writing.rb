writer = File.open("test.txt", "w")
reader = File.open("test.txt")
AUTO_FLUSH_BYTE = 8000

begin
  10000000.times do |i|
    writer.puts(i.to_s * AUTO_FLUSH_BYTE)
    format("%0#{AUTO_FLUSH_BYTE}d", i)
    puts reader.gets&.slice(-8..-1) if i % 2 == 0
    sleep 2
  end
ensure
  file.close
end

# $ ruby can_readfile_when_writing.rb
#
# 0000000
# 1111111
# 2222222
# 3333333
# ^Ccan_readfile_when_writing.rb:9:in `sleep': Interrupt
#
# このときtest.txtにはi=8のときの値まで記載されていた。
#
# ↓
# ファイル書き込み中に全く独立したreaderでファイル読み込みができる