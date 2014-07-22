class ModAsset < ActiveRecord::Base

  belongs_to :mod_version

  has_attached_file :image, styles: { medium: '300x300>', thumb: '100x100>', full: '1920x1080>' }
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/

  ### Validations
  ###############

  validate :has_image_or_video?
  validate :valid_video_provider?, if: :video?

  def has_image_or_video?
    if video? == !image.blank? # if not nothing, or if everything
      errors[:base] << 'Asset should have a video XOR an image'
    end
  end

  def valid_video_provider?
    if video_provider == :unknown
      errors[:video_url] << 'Invalid video provider, the only valid video provider is YouTube'
    end
  end

  ### Attributes
  ##############

  alias_attribute :version, :mod_version

  delegate :number, to: :version, prefix: true

  def video?
    !video_url.blank?
  end

  def video_provider
    if video_url
      if YouTubeAddy.extract_video_id(video_url).kind_of? String
        return :youtube
      end
    end

    :unknown
  end

  def video_embed_url
    case video_provider
    when :youtube
      "http://www.youtube.com/embed/#{youtube_video_key}"
    else
      nil
    end
  end

  private

  def youtube_video_key
    YouTubeAddy.extract_video_id(video_url)
  end
end