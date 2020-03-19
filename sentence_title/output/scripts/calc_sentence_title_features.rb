require "csv"

$is_debug = true

def main(csv)
  csv_cols = ["end_with_noun?", "with_space?", "only_one_noun?", "with_descriptive_noun?", "with_particle?", "with_relative?"]
  results = csv_cols.each_with_object({}) do |col, result_hash|
    result_hash[col] = 0
  end

  FileHandler.csv_foreach(csv) do |row|
    results.each do |col, count|
      results[col] = row[col].to_i + count
    end
  end

  all_count = FileHandler.line_count(csv)
  puts "レコード数: #{all_count}"
  results.each do |col, count|
    puts "#{col}: #{count} (#{CommonUtilities.percent(count, all_count)}%)"
  end
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
      "#{Time.now}: #{CommonUtilities.percent(current_count, all_count)}% (#{current_count}/#{all_count})"
    end
  end
end

module CommonUtilities
  class << self
    def percent(num, all_count)
      (num.fdiv(all_count) * 100).round(2)
    end
  end
end

main(ARGV[0])