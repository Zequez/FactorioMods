class Scraper::SubforumManager
  def initialize(subforums)
    @subforums = subforums
  end

  def run
    @forum_posts = []
    urls = @subforums.map(&:url)
    scraper = Scraper::Base.new(urls)
    posts_data = scraper.scrap
    @subforums.each do |subforum|
      subforum_posts_data = posts_data[subforum.url]
      process_posts(subforum, subforum_posts_data)
    end
  end

  def process_posts(subforum, posts_data)
    forum_posts = posts_data.map do |post_data|
      forum_post = ForumPost.find_or_initialize_by(post_number: post_data[:post_number])
      forum_post.title =          post_data[:title]
      forum_post.published_at =   post_data[:published_at]
      forum_post.last_post_at =   post_data[:last_post_at]
      forum_post.views_count =    post_data[:views_count]
      forum_post.comments_count = post_data[:comments_count]
      forum_post.author_name =    post_data[:author_name]
      forum_post.url =            post_data[:url]
      forum_post.subforum =       subforum
      forum_post.save! # This should never happen, as there are no validations. But if it happens, I want to know.
      forum_post
    end

    subforum.update_column(:last_scrap_at, Time.now)

    @forum_posts.concat(forum_posts)
  end
end