require "csv"

$is_debug = true

def main(csv, pickup_count)
  output_file = output_filename(csv, pickup_count)
  output_file_writer = CSV.open(output_file, "w")

  output_cols = csv_header_from(csv)
  output_file_writer.puts(output_cols)

  pickuped_count = 0
  csv_row_size = FileHandler.line_count(csv)

  while pickuped_count < pickup_count
    FileHandler.csv_foreach(csv) do |row|
      next if pickuped_count >= pickup_count

      next unless pickup_now?(pickup_count, csv_row_size)

      output_file_writer.puts(row)
      pickuped_count += 1
    end
  end

  puts "#{output_file}を作成しました"
  output_file_writer.close
end

def output_filename(source_csv, pickup_count)
  dir_elements = source_csv.split("/")

  file = dir_elements.last
  file = "pickup_#{pickup_count}_#{file}"
  dir_elements[-1] = file

  dir_elements.join("/")
end

def csv_header_from(target_csv)
  csv = CSV.open(target_csv)
  header = csv.readline
  csv.close

  header
end

def pickup_now?(pickup_count, target_count)
  # 例 10,000個から1,000個取る場合。数が1/10になる=10,000/1,000
  rand(target_count / pickup_count) + 1 == 1
end

module FileHandler
  class << self
    def csv_foreach(csv)
      log "#{Time.now}: read start #{csv}"
      all_line_count = line_count(csv)

      return_values = CSV.foreach(csv, headers: true).with_index(1).map do |row, row_no|
        log progress(row_no, all_line_count) if progress_timing?(all_line_count, row_no)
        yield(row)
      end

      log "#{Time.now}: read end #{csv}"

      return_values
    end

    def line_count(file)
      open(file){|f|
        while f.gets; end
        f.lineno
      }
    end

    private

    def log(message)
      puts(message) if $is_debug
    end

    def progress_timing?(all_line_count, line_no)
      return false if all_line_count < 100

      # NOTE 処理時間によって変更
      div_number = 100

      percent_unit = all_line_count / div_number
      line_no % percent_unit == 0
    end

    def progress(current_count, all_count)
      "#{Time.now}: #{CommonUtilities.percent(current_count, all_count)}% (#{CommonUtilities.number_with_commma(current_count)} / #{CommonUtilities.number_with_commma(all_count)})"
    end
  end
end

module CommonUtilities
  class << self
    def percent(num, all_count)
      (num.fdiv(all_count) * 100).round(2)
    end

    def number_with_commma(number)
      number.to_s.gsub(/(\d)(?=\d{3}+$)/, '\\1,')
    end
  end
end

main(ARGV[0], ARGV[1].to_i)