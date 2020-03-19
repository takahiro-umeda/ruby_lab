require "csv"

$is_debug = true

def main(csv, condition_str)
  output_file_writer = CSV.open(output_csvname(csv, condition_str), "w")
  output_cols = ["title", "end_with_noun?", "with_space?", "only_one_noun?", "with_descriptive_noun?", "with_particle?", "with_relative?", "words"]
  output_file_writer.puts(output_cols)

  FileHandler.csv_foreach(csv) do |row|

    end_with_noun = row["end_with_noun?"] == "1"
    with_space = row["with_space?"] == "1"
    only_one_noun = row["only_one_noun?"] == "1"
    with_descriptive_noun = row["with_descriptive_noun?"] == "1"
    with_particle = row["with_particle?"] == "1"
    with_relative = row["with_relative?"] == "1"

    next unless eval(condition_str)

    output_row_values = row
    output_file_writer.puts(output_row_values)
  end

  output_file_writer.close
end

def output_csvname(input_csv, condition_str)
  input_csvname = input_csv.split("/").last.gsub(/\.csv/, "")
  condition_for_name = condition_str.gsub(/ /, "_")
  "#{input_csvname}_extracting_#{condition_for_name}.csv"
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



main(ARGV[0],ARGV[1])