class Polls::Questions::QuestionComponent < ApplicationComponent; end

load Rails.root.join("app", "components", "polls", "questions", "question_component.rb")

class Polls::Questions::QuestionComponent
  attr_reader :questions, :index

  def initialize(questions, question, index)
    @questions = questions
    @question = question
    @index = index
  end
end
