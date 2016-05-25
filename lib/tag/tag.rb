module PriceTags
  class Tag
    def initialize(product)
      @product = product
      ## Make a copy to compare
      @initial_product_tags = product.tags
    end

    def self.process_all_tags
      Product.all_products_array.each do |page|
        page.each do |product|
          Tag.new(product).add_price_tags
        end
      end
    end

    def self.process_recent_tags
      Product.recent_products_array.each do |page|
        page.each do |product|
          Tag.new(product).add_price_tags
        end
      end
    end

    def custom_price_tag
      'price_' + @product.price.gsub('.','')
    end

    def removed_initial_tags
      @product.tags.gsub /price_\d+/ ,' '
    end

    def add_price_tags

      ## Remove the old price tags
      @product.tags = removed_initial_tags

      if has_variants?
        variants.each do |variant|
          @product.tags = [@product.tags,price_tag(variant)].join(',')
        end
      end

      puts "#{initial_tags} ====> #{cleaned_tags}"
      if tags_changed?
        # puts "#{@product.title} : Updated Tags!"
        @product.tags = cleaned_tags
        @product.save!
        sleep(1.second) ## For the API
      else
        # puts "#{@product.title} : No Change in Tags!"
      end
    end

    def has_variants?
      variants.any?
    end

    def variants
      @product.variants
    end

    def cleaned_tags
      @product.tags.split(',').reject{ |c| c.empty? or c == "  " }.uniq.join(',')
    end

    def initial_tags
      @initial_product_tags
    end

    def tags_changed?
      clean_tags(initial_tags) != clean_tags(cleaned_tags)
    end

    def clean_tags(tags)
      tags.split(',').map{ |t| t.strip }.uniq.sort
    end

    def price_tag(v)
      ## no empty or blank prices please!
      if !v.price.blank? or v.price != '0.00'
        'price_' + v.price.gsub('.','')
      else
        nil
      end
    end

  end
end
