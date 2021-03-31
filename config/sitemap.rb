# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = 'https://premesti-se.trk.in.rs/'

SitemapGenerator::Sitemap.create do
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, :priority => 0.7, :changefreq => 'daily'
  #
  # Add all articles:
  #
  #   Article.find_each do |article|
  #     add article_path(article), :lastmod => article.updated_at
  #   end
  add all_moves_path
  add active_chats_path
  Chat.active.find_each do |chat|
    add public_chat_path(chat, chat.name_with_arrows)
  end
  Move.find_each do |move|
    add public_move_path(move, move.group_age_and_locations_en), lastmod: move.updated_at
  end

end
