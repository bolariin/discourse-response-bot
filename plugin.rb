# name: response-bot
# about: Replies new topic with default wiki post
# version: 0.1
# authors: Bolarinwa Balogun
# url: https://github.com/bolariin/response-bot

enabled_site_setting :response_enabled

after_initialize do

    class ::Category

        def self.reset_enabled_cache
            @@enable_response_cache["allowed"] =
            begin
                Set.new(
                    CategoryCustomField
                    .where(name: "enable_response_bot", value: "true")
                    .pluck(:category_id)
                )
            end
        end

        def self.reset_disabled_cache
            @@disable_response_cache["allowed"] =
            begin
                Set.new(
                    CategoryCustomField
                    .where(name: "disable_response_bot", value: "true")
                    .pluck(:category_id)
                )
            end
        end
  
        @@enable_response_cache = DistributedCache.new("enable_response")
        @@disable_response_cache = DistributedCache.new("disable_response")

        def self.is_response_bot_enabled_on_category?(category_id)

            unless (enabled_set = @@enable_response_cache["allowed"] && disabled_set = @@disable_response_cache["allowed"])
                enabled_set = ::Category.reset_enabled_cache
                disabled_set = ::Category.reset_disabled_cache
            end

            if SiteSetting.allow_response_bot_to_reply_all_new_topics
                return !(disabled_set.include?(category_id))
            end
            enabled_set.include?(category_id)
        end

        def self.can_respond?(topic)
            SiteSetting.response_enabled && ::Category.is_response_bot_enabled_on_category?(topic.category_id) && (!topic.closed?)
        end
  
        after_save :reset_enabled_cache
        after_save :reset_disabled_cache
  
        protected
        def reset_enabled_cache
          ::Category.reset_enabled_cache
        end

        protected
        def reset_disabled_cache
            ::Category.reset_disabled_cache
        end
    end

    ## Check if user already exists
    ## using a negative number to ensure it is unique
    bot = User.find_by(id: -10)

    if !bot
        response_username = "student_response"
        response_name = "Student Reponse"
    
        # user created
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

    ## event listener for creation of new topic
    ## once a topic is created, automatically reply topic with wiki post
    DiscourseEvent.on(:topic_created) do |topic|
        if ::Category.can_respond?(topic)
            post = PostCreator.create(bot,
                        topic_id: topic.id,
                        raw: I18n.t('bot.default_message'))
            post.wiki = true
            post.save(validate: false)
        end
    end
end
