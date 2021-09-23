type status = {
  passedAt: option<Js.Date.t>,
  feedbackSent: bool,
}

type t = {
  id: string,
  title: string,
  createdAt: Js.Date.t,
  userNames: string,
  status: option<status>,
  teamName: option<string>,
  levelNumber: int,
  reviewerName: option<string>,
  reviewerAssignedAt: option<Js.Date.t>,
}

let id = t => t.id
let title = t => t.title
let createdAt = t => t.createdAt
let levelNumber = t => t.levelNumber
let userNames = t => t.userNames
let teamName = t => t.teamName
let reviewerName = t => t.reviewerName
let reviewerAssignedAt = t => t.reviewerAssignedAt

let failed = t =>
  switch t.status {
  | None => false
  | Some(status) => OptionUtils.mapWithDefault(_ => false, true, status.passedAt)
  }

let pendingReview = t => OptionUtils.mapWithDefault(_ => false, true, t.status)

let feedbackSent = t => OptionUtils.mapWithDefault(status => status.feedbackSent, false, t.status)

let createdAtPretty = t => t.createdAt->DateFns.format("MMMM d, yyyy")

let timeDistance = t => t.createdAt->DateFns.formatDistanceToNowStrict(~addSuffix=true, ())

let make = (
  ~id,
  ~title,
  ~createdAt,
  ~userNames,
  ~status,
  ~teamName,
  ~levelNumber,
  ~reviewerName,
  ~reviewerAssignedAt,
) => {
  id: id,
  title: title,
  createdAt: createdAt,
  userNames: userNames,
  status: status,
  teamName: teamName,
  levelNumber: levelNumber,
  reviewerName: reviewerName,
  reviewerAssignedAt: reviewerAssignedAt,
}

let makeStatus = (~passedAt, ~feedbackSent) => {passedAt: passedAt, feedbackSent: feedbackSent}

let makeFromJS = submission => {
  let status =
    submission["evaluatedAt"]->Belt.Option.map(_ =>
      makeStatus(
        ~passedAt=submission["passedAt"]->Belt.Option.map(DateFns.decodeISO),
        ~feedbackSent=submission["feedbackSent"],
      )
    )

  make(
    ~id=submission["id"],
    ~title=submission["title"],
    ~createdAt=DateFns.decodeISO(submission["createdAt"]),
    ~userNames=submission["userNames"],
    ~status,
    ~teamName=submission["teamName"],
    ~levelNumber=submission["levelNumber"],
    ~reviewerName=submission["reviewerName"],
    ~reviewerAssignedAt=Belt.Option.map(submission["reviewerAssignedAt"], DateFns.decodeISO),
  )
}

let replace = (e, l) => l |> Array.map(s => s.id == e.id ? e : s)

let statusEq = (overlaySubmission, t) =>
  switch (t.status, CoursesReview__OverlaySubmission.evaluatedAt(overlaySubmission)) {
  | (None, None) => true
  | (Some({passedAt}), Some(_)) =>
    passedAt == CoursesReview__OverlaySubmission.passedAt(overlaySubmission)
  | (Some(_), None)
  | (None, Some(_)) => false
  }
