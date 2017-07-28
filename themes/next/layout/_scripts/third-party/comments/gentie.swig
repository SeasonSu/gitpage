{% if not (theme.duoshuo and theme.duoshuo.shortname) and not theme.duoshuo_shortname and not theme.disqus_shortname and not theme.hypercomments_id %}

  {% if theme.gentie_productKey %}
    {% set gentie_productKey = theme.gentie_productKey %}
    <script>
        if($('.page-post-detail').length > 0 || window.location.href.indexOf('guestbook') > -1){
            var cloudTieConfig = {
              url: document.location.href,
              sourceId: "",
              productKey: "{{gentie_productKey}}",
              target: "cloud-tie-wrapper"
            };
           var oHead = document.getElementsByTagName('head').item(0);
           var oScript = document.createElement('script');
           oScript.type = 'text/javascript';
           oScript.src = 'https://img1.ws.126.net/f2e/tie/yun/sdk/loader.js';
           oHead.appendChild(oScript);
        }
    </script>

  {% endif %}

{% endif %}
