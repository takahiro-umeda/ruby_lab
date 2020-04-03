require "natto"

module Tokenize
  class Tokenizer
    @@natto_mecab = Natto::MeCab.new

    class << self
      def exec(sentence)
        words = []
        target_sentence = normalize(sentence)
        @@natto_mecab.parse(target_sentence) do |node|
          next if node.is_eos?
          words << TokenizedWord.new(node)
        end
        return if words.empty?
        TokenizedSentence.new(target_sentence, words)
      end

      private

      def normalize(original_str)
        str = original_str.dup
        str.gsub!(/（/, "(")
        str.gsub!(/）/, ")")
        str.gsub!(/　/, " ")
        str.gsub!(/"/, "")
        str
      end
    end
  end

  class TokenizedSentence
    attr_reader :words, :score

    def initialize(sentence, words)
      @sentence = sentence
      @words = words
    end

    def to_s
      @sentence
    end

    def specified_part_of_speech_size(part_of_speech)
      @words.select {|word| word.send("#{part_of_speech}?")}.size
    end

    def not_specified_part_of_speech_size(part_of_speech)
      @words.reject {|word| word.send("#{part_of_speech}?")}.size
    end

  end

  class TokenizedWord
    attr_reader :original_word, :part_of_speech

    PARTS_OF_SPEECH = {
      NOUN: "名詞",
      VERB: "動詞",
      ADJECTIVE: "形容詞",
      ADJECTIVE_VERB: "形容動詞",
      RENTAISHI: "連体詞",
      ADVERB: "副詞",
      CONJUNCTION: "接続詞",
      INTERJECTION: "感動詞",
      PARTICLE: "助詞",
      AUXILIARY_VERB: "助動詞",
      SYMBOL: "記号",
      ARTICLE: "冠詞",
      PREPOSITION: "前置詞",
      INTERROGATIVE: "疑問詞",
    }

    PARTS_OF_SPEECH.each do |pos_en, pos_ja|
      define_method("#{pos_en.to_s.downcase}?") do
        @part_of_speech == pos_ja
      end
    end

    def initialize(natto_node)
      @original_word = natto_node.surface
      @tokenize_result_str = natto_node.feature
      tokenize_results = natto_node.feature.split(",")

      @part_of_speech = tokenize_results[0]
    end

    def to_s
      @original_word
    end
  end

  class SentenceReviewer
    SPACE_SENTENCE_SCORE = -1
    NOT_END_WITH_NOUN_SCORE = -2
    ONLY_ONE_NOUN = -3

    class << self
      def exec(tokenized_sentence)
        @sentence = tokenized_sentence
        result = {
          "title" => tokenized_sentence.to_s,
          # "words" => @sentence.words.map {|word| [word.to_s, word.part_of_speech]}.to_h
        }
        check_methods.each_with_object(result) do |check_method, result_hash|
          result_hash[check_method] = send(check_method) ? 1 : 0
        end
      end

      def result_keys
        sentence_properties.concat(check_methods)
      end

      def sentence_properties
        [
          "title",
        # "words"
        ]
      end

      def check_methods
        [
          "with_space?",
          "with_one_space?",
          "with_more_than_one_spaces?",
          "end_with_noun?",
          "only_one_noun_block?",
          "more_than_15_chars?",
          "with_descriptive_noun?",
          "with_particle?",
          "with_relative?"
        ]
      end

      private

      def end_with_noun?
        @sentence.words.last.noun?
      end

      def with_space?
        !@sentence.to_s.match(/ /).nil?
      end

      def with_one_space?
        space_count  == 1
      end

      def with_more_than_one_spaces?
        space_count > 1
      end

      def space_count
        @sentence.to_s.count(" ")
      end

      # bad_title_conditions
      def only_one_noun_block?
        return false if with_space?
        @sentence.not_specified_part_of_speech_size("noun") == 0
      end

      # good_title_conditions
      def more_than_15_chars?
        @sentence.to_s.length > 15
      end

      def with_descriptive_noun?
        end_with_noun? && @sentence.not_specified_part_of_speech_size("noun") > 0
      end

      def with_particle?
        @sentence.specified_part_of_speech_size("particle") > 0
      end

      # 関係詞(動詞を含む)
      def with_relative?
        @sentence.specified_part_of_speech_size("verb") > 0
      end
    end
  end
end

if __FILE__ == $0
  # デバッグコード
  sentence = ARGV[0]

  tokenized_sentence = Tokenize::Tokenizer.exec(sentence)
  review_result = Tokenize::SentenceReviewer.exec(tokenized_sentence)
  p review_result
end