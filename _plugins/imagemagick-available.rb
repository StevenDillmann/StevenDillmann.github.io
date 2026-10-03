# Only advertise responsive .webp variants when ImageMagick can actually generate them.
# Without it (e.g. a local machine without `brew install imagemagick`) the <source> tags
# point at missing files and the browser shows the image's alt text until a reload.
Jekyll::Hooks.register :site, :after_init do |site|
  available = %w[magick convert].any? { |cmd| system("command -v #{cmd} > /dev/null 2>&1") }
  site.config['imagemagick_available'] = available
  Jekyll.logger.info "ImageMagick:", available ? "found, responsive images enabled" : "not found, serving original images only"
end
