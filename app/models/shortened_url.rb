class ShortenedUrl < ActiveRecord::Base
  validates :short_url, :presence => true, :uniqueness => true
  validates :submitter_id, :presence => true

  # these stuffs are associations
  belongs_to(
    :user,
    class_name: :User,
    foreign_key: :submitter_id,
    primary_key: :id
  )

  has_many(
    :visits,
    class_name: :Visit,
    foreign_key: :shortened_url_id,
    primary_key: :id
  )

  has_many(
    :visitors,
    Proc.new { distinct }, #<<<
    through: :visits,
    source: :user
  )
  # has many here just ties associations together

  def self.random_code
    # shortenened_urls.short_url = SecureRandom::urlsafe_base64
    short_url = SecureRandom.urlsafe_base64
    while ShortenedUrl.exists?(:short_url => short_url)
      short_url = SecureRandom.urlsafe_base64
    end
    short_url
  end

  def self.create_for_user_and_long_url!(user, long_url)
    ShortenedUrl.create!(
      long_url: long_url,
      short_url: ShortenedUrl.random_code,
      submitter_id: user.id
    )
  end

  def num_clicks
    Visit.count(:user_id)
  end

  def num_uniques
    # Visit.distinct.count(:user_id)
    visitors.count
  end

  def num_recent_uniques
    Visit.where("created_at > ?", 10.hours.ago).distinct.count(:user_id)
  end
end
