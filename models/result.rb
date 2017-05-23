class Result

  attr_accessor :question

  def initialize(question)
    @question = question
  end

  def colors
    ['#e74c3c', '#2ecc71', '#f1c40f', '#3498db', '#9b59b6', '#e67e22', '#1abc9c', '#34495e', '#95a5a6', '#ecf0f1']
  end

  def highlight
    ['#c0392b', '#27ae60', '#f39c12', '#2980b9', '#8e44ad', '#d35400', '#16a085', '#2c3e50', '#7f8c8d', '#bdc3c7']
  end

  def text_inputs
    answer = Answer.dataset.where(question: question).reverse_order(:id).all
  end

  def images
    question = self.question.actual
    options = question.options
    result = {
        labels: [],
        datasets: []
    }
    ds = {
        label: "Option",
        fillColor: '#3498db',
        strokeColor: '#3498db',
        highlightFill: '#2980b9',
        highlightStroke: '#2980b9',
        data: []
    }
    options.each_with_index do |option, index|
      result[:labels] << option.optionText
      #TODO: This query is incorrect
      ds[:data] << Answer.where(question: question).where(Sequel.like(:content, '%' + option.optionText + '%')).count || 0
    end
    result[:datasets] << ds
    return result
  end
  def multiple_choices
    question = self.question.actual
    options = question.options
    if !question.multiple_selection
      result = []
      options.each_with_index do |option, index|
        t = {
            label: option.optionText,
            value: Answer.where(question: question).where(content: option.option_translations.first.content).count || 0,
            color: colors[index],
            highlight: highlight[index]
        }
        result << t
      end
      return result
    else
      result = {
          labels: [],
          datasets: []
      }
      ds = {
          label: "Option",
          fillColor: '#3498db',
          strokeColor: '#3498db',
          highlightFill: '#2980b9',
          highlightStroke: '#2980b9',
          data: []
      }
      allAnswers = Answer.where(question: question).all
      options.each_with_index do |option, index|
        result[:labels] << option.optionText
        #TODO: This query is incorrect
        ds[:data] << allAnswers.select{|aw| !aw[:content].downcase.split(',').index(option.optionText.downcase).nil?}.count || 0

      end
      result[:datasets] << ds
      return result
    end
  end

  def star_ratings

    result = {}
    result[:labels] = ["1 \u2605", "2 \u2605", "3 \u2605", "4 \u2605", "5 \u2605"];
    result[:datasets] = []

    ds = {
        label: "Rating",
        fillColor: '#3498db',
        strokeColor: '#3498db',
        highlightFill: '#2980b9',
        highlightStroke: '#2980b9',
        data: []
    }

    for i in 1..5

      data = Answer.where(question: question).where(content: i.to_s).count || 0

      ds[:data] << data
    end

    result[:datasets] << ds
    return result
  end

  def smiley_faces

    result = {}
    result[:labels] = ["Bored", "Normal", "Happy", "Excited"];
    result[:datasets] = []

    ds = {
        label: "Rating",
        fillColor: '#3498db',
        strokeColor: '#3498db',
        highlightFill: '#2980b9',
        highlightStroke: '#2980b9',
        data: []
    }

    for i in 1..4

      data = Answer.where(question: question).where(content: i.to_s).count || 0

      ds[:data] << data
    end

    result[:datasets] << ds
    return result
  end

  def publish
    @publish||= case question.question_type.id
                  when QuestionType::STAR_RATING
                    star_ratings
                  when QuestionType::MULTIPLE_CHOICES
                    multiple_choices
                  when QuestionType::TEXT_INPUT
                    text_inputs
                  when QuestionType::SMILE_FACE
                    smiley_faces
                  when QuestionType::IMAGE
                    images
                end

  end
end
