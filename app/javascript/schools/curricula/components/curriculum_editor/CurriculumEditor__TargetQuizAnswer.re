[@bs.config {jsx: 3}];

open CurriculumEditor__Types;

let str = React.string;

[@react.component]
let make =
    (
      ~answerOption: AnswerOption.t,
      ~updateAnswerOptionCB,
      ~removeAnswerOptionCB,
      ~canBeDeleted,
      ~markAsCorrectCB,
      ~answerOptionId,
    ) =>
  <div className="relative">
    {
      answerOption |> AnswerOption.correctAnswer ?
        <div
          className="quiz-maker__answer-option-pointer flex justify-center items-center quiz-maker__answer-option-pointer--correct">
          <Icon kind=Icon.Check size="2" />
        </div> :
        <div
          onClick={
            _event => {
              ReactEvent.Mouse.preventDefault(_event);
              markAsCorrectCB(answerOption |> AnswerOption.id);
            }
          }
          className="quiz-maker__answer-option-pointer cursor-pointer">
          ReasonReact.null
        </div>
    }
    <div
      id={answerOptionId ++ "_block"}
      className="flex flex-col bg-white mb-2 border rounded ml-12">
      <div className="flex">
        <textarea
          id=answerOptionId
          className="appearance-none block w-full bg-white text-gray-800 text-sm rounded px-4 py-3 leading-tight focus:outline-none focus:bg-white focus:border-gray-500"
          placeholder="Answer option (supports markdown)"
          value={answerOption |> AnswerOption.answer}
          onChange={
            event =>
              updateAnswerOptionCB(
                answerOption |> AnswerOption.id,
                answerOption
                |> AnswerOption.updateAnswer(
                     ReactEvent.Form.target(event)##value,
                   ),
              )
          }
        />
        <button
          className={
            answerOption |> AnswerOption.correctAnswer ?
              "w-28 flex-shrink-0 border border-l-1 border-r-0 border-t-0 border-b-0 text-green-500 font-semibold cursor-default focus:outline-none text-xs py-1 px-2" :
              "w-28 flex-shrink-0 border border-l-1 border-r-0 border-t-0 border-b-0 text-gray-500 hover:text-gray-800 focus:outline-none text-xs py-1 px-2"
          }
          type_="button"
          onClick={
            _event => {
              ReactEvent.Mouse.preventDefault(_event);
              markAsCorrectCB(answerOption |> AnswerOption.id);
            }
          }>
          {
            answerOption |> AnswerOption.correctAnswer ?
              "Correct Answer" |> str : "Mark as correct" |> str
          }
        </button>
        {
          canBeDeleted ?
            <button
              className="flex-shrink-0 border border-l-1 border-r-0 border-t-0 border-b-0 text-gray-500 hover:text-gray-800 focus:outline-none text-xs py-1 px-2"
              type_="button"
              onClick={
                event => {
                  ReactEvent.Mouse.preventDefault(event);
                  removeAnswerOptionCB(answerOption |> AnswerOption.id);
                }
              }>
              {"Remove" |> str}
            </button> :
            ReasonReact.null
        }
      </div>
    </div>
  </div>;
