# name: response-bot
# about: Replies new topic with default wiki post
# version: 0.1
# authors: Bolarinwa Balogun
# url: https://github.com/bolariin/response-bot

enabled_site_setting :response_enabled

after_initialize do

    class ::Category

        def self.reset_response_cache
            @@enable_response_cache["allowed"] =
            begin
                Set.new(
                    CategoryCustomField
                    .where(name: "enable_response_bot", value: "true")
                    .pluck(:category_id)
                )
            end
        end
  
        @@enable_response_cache = DistributedCache.new("enable_response")
  
        def self.is_response_bot_enabled_on_category?(category_id)
            return true if SiteSetting.allow_response_bot_to_reply_all_new_topics

            unless set = @@enable_response_cache["allowed"]
                set = ::Category.reset_response_cache
            end
            set.include?(category_id)
        end

        def self.can_respond?(topic)
            SiteSetting.response_enabled && ::Category.is_response_bot_enabled_on_category?(topic.category_id) && (!topic.closed?)
        end
  
        after_save :reset_response_cache
  
        protected
        def reset_response_cache
          ::Category.reset_response_cache
        end
    end
  

    # Check if user already exists
    # using a negative number to ensure it is unique
    user = User.find_by(id: -10)

    # user created
    if !user
        response_username = "student_response"
        response_name = "Student Reponse"
        
        user = User.new
        user.id = -10
        user.name = response_name
        user.username = response_username
        user.email = "student_response@me.com"
        user.username_lower = response_username.downcase
        user.password = SecureRandom.hex
        user.active = true
        user.approved = true
        user.trust_level = TrustLevel[1]
    end

    # event listener for creation of new topic
    # once a topic is created, automatically reply topic with wiki post
    DiscourseEvent.on(:topic_created) do |topic|
        if ::Category.can_respond?(topic)
            post = PostCreator.create(user,
                        topic_id: topic.id,
                        raw: I18n.t('bot.default_message'))
            post.wiki = true
            post.save(validate: false)
        end
    end
end
