import property from 'ember-addons/ember-computed-decorators';
import Category from 'discourse/models/category';

export default {
  name: 'extend-category-for-response-bot',
  before: 'inject-discourse-objects',
  initialize() {

    Category.reopen({
      /*
       * Custom field, enable_response_bot is added to 
       * category. It can either be true or false.
       * It is related to feature that allows the admin
       * enable response bot in the choosen
       * category. 
      */
      @property('custom_fields.enable_response_bot')
      enable_response_bot: {
        get(enableField) {
          return enableField === "true";
        },
        set(value) {
          value = value ? "true" : "false";
          this.set("custom_fields.enable_response_bot", value);
          return value;
        }
      },

      /*
       * Custom field, disable_response_bot is added to 
       * category. It can either be true or false.
       * It is related to feature that allows the admin
       * disable responses by response bot in the choosen
       * category.
      */
      @property('custom_fields.disable_response_bot')
      disable_response_bot: {
        get(enableField) {
          return enableField === "true";
        },
        set(value) {
          value = value ? "true" : "false";
          this.set("custom_fields.disable_response_bot", value);
          return value;
        }
      }
      
    });
  }
};

