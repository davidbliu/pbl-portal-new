require 'trello'
class ParseTrelloCard < ParseResource::Base
	fields :card_id, :list_id, :board_id, :assigned_emails, :assigner_emails

end