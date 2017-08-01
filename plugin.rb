# name: response-bot
# about: Replies new topic with default wiki post
# version: 0.1
# authors: Bolarinwa Balogun
# url: https://github.com/bolariin/response-bot

enabled_site_setting :response_enabled

after_initialize do
    
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
end