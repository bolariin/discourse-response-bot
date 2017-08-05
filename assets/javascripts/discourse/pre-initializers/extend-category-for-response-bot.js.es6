import property from 'ember-addons/ember-computed-decorators';
import Category from 'discourse/models/category';

export default {
  name: 'extend-category-for-response-bot',
  before: 'inject-discourse-objects',
  initialize() {

    Category.reopen({
      
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

