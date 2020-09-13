class UsersDatatable < TrkDatatables::Neo4j
  def columns
    {
      'users.email': {},
      'integer_calculated_in_db.moves': {search: false, order: false, title: 'Moves/Shared'},
      'integer_calculated_in_db.chats': {search: false, order: false},
      'users.created_at': {},
      '': {},
    }
  end

  def all_items
    User
      .as(:users)
      .with_associations(moves: { from_group: [:location], to_groups: [:location] })
      .order(created_at: :desc)
  end

  def rows(filtered)
    filtered.map do |user|
      email_and_social = user.email.html_safe
      email_and_social.prepend '<i class="fa fa-facebook-official"></i> '.html_safe if user.facebook_uid.present?
      email_and_social.prepend '<i class="fa fa-google" aria-hidden="true"></i> '.html_safe if user.google_uid.present?
      email_and_social.prepend '<span class="badge badge-primary">admin</span> '.html_safe if user.admin?
      email_and_social += ' <span class="badge badge-danger">unconfirmed</span>'.html_safe unless user.confirmed?
      login_as = @view.link_to 'sign_in_as', @view.sign_in_as_path(user_id: user.id)
      # <% user.moves.each do |move| %>
      #   <%= move.group_age_and_locations %>
      # <% end %>
      [
        @view.link_to(email_and_social, @view.admin_user_path(user)),
        "#{user.moves.size} / #{user.shared_moves.size}",
        "#{user.moves.chats.active.size} / #{user.shared_chats.size}",
        user.created_at.to_s(:long),
        login_as,
      ]
    end
  end
end
