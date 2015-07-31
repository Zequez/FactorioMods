class ModFileSerializer < ActiveModel::Serializer
  attributes :id, :name, :mirror, :url

  def url
    object.download_url.presence || nil
  end

  def mirror
    object.attachment.present? ? object.attachment.url : nil
  end
end
