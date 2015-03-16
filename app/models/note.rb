class Note < ActiveRecord::Base

  KIND_TYPES    = %w(log note reason followup).freeze
  REASON_TYPES  = %w(this that and the other thing).freeze

  acts_as_paranoid

  belongs_to :notable, polymorphic: true
  belongs_to :user

  validates_inclusion_of :kind, in: KIND_TYPES
  validates_inclusion_of :reason, in: REASON_TYPES,
                                  if: Proc.new { |note| note.reason.present? }

  def comment
    case kind
    when 'followup'
      [
        'Followup',
        notable.follow_up_date.strftime('%F'),
        read_attribute(:comment)
      ].join(': ')
    else
      read_attribute(:comment)
    end
  end

  def reason?
    kind == 'reason'
  end

  def followup?
    kind == 'followup'
  end

  def log?
    kind == 'log'
  end

  def note?
    kind == 'note'
  end
end
