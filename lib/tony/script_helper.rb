module Tony
  module ScriptHelper
    def timezone_script
      return <<~JS
        <script type="text/javascript">
          const tz = Intl.DateTimeFormat().resolvedOptions().timeZone;
          document.cookie = "tz="+tz+"; expires=31536000; path=/";
          document.documentElement.classList.add('timezone-loaded');
        </script>
      JS
    end
  end
end
