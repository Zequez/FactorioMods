class MultiAuthorsUpdater
  def update
    Mod.all.each do |mod|
      if mod.authors.empty?
        if mod.author
          mod.authors << mod.author
          mod.save!
        elsif mod.author_name.present?
          mod.authors_list = mod.author_name
          mod.save!
        end
      end
    end
  end
end