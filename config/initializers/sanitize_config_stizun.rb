class Sanitize
  module Config
    STIZUN = {
      :elements => [
        'h3','h4','h5','a', 'b', 'blockquote', 'br', 'cite', 'code', 'dd', 'dl', 'dt', 'em',
        'i', 'li', 'ol', 'p', 'pre', 'q', 'small', 'strike', 'strong', 'sub',
        'sup', 'u', 'ul'],

      :attributes => {
        'a'          => ['href'],
        'blockquote' => ['cite'],
        'q'          => ['cite']
      },

      :add_attributes => {
        'a' => {'rel' => 'nofollow'}
      },

      :protocols => {
        'a'          => {'href' => ['ftp', 'http', 'https', 'mailto',
                                    :relative]},
        'blockquote' => {'cite' => ['http', 'https', :relative]},
        'q'          => {'cite' => ['http', 'https', :relative]}
      }
    }
  end
end