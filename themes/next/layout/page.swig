{% extends '_layout.swig' %}
{% import '_macro/sidebar.swig' as sidebar_template %}

{% block title %}
  {% set page_title_suffix = ' | ' + config.title %}

  {% if page.type === "categories" and not page.title  %}
    {{ __('title.category') + page_title_suffix }}
  {% elif page.type === "tags" and not page.title  %}
    {{ __('title.tag') + page_title_suffix }}
  {% else %}
    {{ page.title + page_title_suffix }}
  {% endif %}
{% endblock %}

{% block content %}

  <div id="posts" class="posts-expand">
  {% include '_partials/page-header.swig' %}
    {# tagcloud page support #}
    {% if page.type === "tags" %}
      <div class="tag-cloud">
        <div class="tag-cloud-title">
            {{ _p('counter.tag_cloud', site.tags.length) }}
        </div>
        <div class="tag-cloud-tags">
          {{ tagcloud({min_font: 12, max_font: 30, amount: 200, color: true, start_color: '#ccc', end_color: '#111'}) }}
        </div>
      </div>
    {% elif page.type === 'categories' %}
      <div class="category-all-page">
        <div class="category-all-title">
            {{ _p('counter.categories', site.categories.length) }}
        </div>
        <div class="category-all">
          {{ list_categories() }}
        </div>
      </div>
    {% else %}
      {{ page.content }}
    {% endif %}
  </div>
   <script>
        var list = document.querySelectorAll('.category-list-item')
        for(var i=0;i<list.length;i++){
            var _this = list[i]
            var nodeList = _this.childNodes
            var hasChild = false
            var listLink = null
            var targetNode = null
            for(var j=0;j<nodeList.length;j++){
               var curNode = nodeList[j];
               if(curNode.getAttribute("class")=='category-list-child'){
                  hasChild = true
                  targetNode = curNode
               }
               if(curNode.getAttribute("class")=='category-list-link'){
                  listLink = curNode
               }
            }
            if(hasChild){
                _this.className += ' noCircle'
                listLink.setAttribute('href','javascript:void(0)')
                listLink.style.color = "#64cbda"
                var spanEle = document.createElement('span')
                spanEle.className = 'triangle'
                _this.insertBefore(spanEle,listLink)
                listLink.addEventListener('click',function(){
                    console.log(this.innerHTML)
                    var cNode = this.parentNode.childNodes
                    var spanNode = null
                    for(var j=0;j<cNode.length;j++){
                       var _curNode = cNode[j];
                       if(_curNode.getAttribute("class").indexOf('triangle') > -1){
                            spanNode = _curNode
                       }

                       if(_curNode.getAttribute("class")=='category-list-child'){
                            if(_curNode.style.display == "none"){
                            _curNode.style.display = "block"
                            spanNode.className = "triangle "
                            }else{
                            _curNode.style.display = "none"
                            spanNode.className = "triangle open"
                            }
                       }
                    }
                })

            }
        }


   </script>
{% endblock %}


{% block sidebar %}
  {{ sidebar_template.render(false) }}
{% endblock %}
