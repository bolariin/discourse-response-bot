# name: response-bot
# about: Replies new topic with default wiki post
# version: 0.1
# authors: Bolarinwa Balogun
# url: https://github.com/bolariin/discourse-response-bot.git

enabled_site_setting :response_enabled

after_initialize do

    class ::Category

        # Stores the category_id of categories with the field 
        # "enable_response_bot" set to true.
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

        # Stores the category_id of categories with the field 
        # "disable_response_bot" set to true.
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
        
        ## DistributedCache is like a hash
        @@enable_response_cache = DistributedCache.new("enable_response")
        @@disable_response_cache = DistributedCache.new("disable_response")

        # Checks if response bot is allowed to make responses
        # in the requested category.
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
        
        # Checks if response bot is allowed to reply a topic.
        def self.can_respond?(topic)
            SiteSetting.response_enabled && 
                ::Category.is_response_bot_enabled_on_category?(topic.category_id) && 
                (!topic.closed?) &&
                (topic.archetype != 'private_message')
        end
        
        # Calls reset_enabled cache and reset_disabled cache
        # after save is made in category settings.
        after_save :reset_enabled_cache
        after_save :reset_disabled_cache
        
        # Updates the enable_response_cache.
        protected
        def reset_enabled_cache
          ::Category.reset_enabled_cache
        end

        # Updates the disable_response_cache.
        protected
        def reset_disabled_cache
            ::Category.reset_disabled_cache
        end
    end


    bot = User.find_by(id: -11)

    # Handles creation of bot if it doesn't exist
    if !bot
        response_username = "responseBot"
        response_name = "Student Response"
    
        # bot created
        bot = User.new
        bot.id = -11
        bot.name = response_name
        bot.username = response_username
        bot.email = "responseBot@me.com"
        bot.username_lower = response_username.downcase
        bot.password = SecureRandom.hex
        bot.active = true
        bot.approved = true
        bot.trust_level = TrustLevel[1]
    end

    ## Event listener listening for creation of a new topic
    ## once a topic is created, automatically reply topic with wiki post
    DiscourseEvent.on(:topic_created) do |topic|
        if ::Category.can_respond?(topic)
            post = PostCreator.create(bot,
                        skip_validations: true,
                        topic_id: topic.id,
                        raw: SiteSetting.response_default_message)
            unless post.nil?
                post.wiki = true
                post.save(validate: false)
            end
        end
    end
end
