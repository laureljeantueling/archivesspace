$(function() {

  $.fn.init_terms_form = function() {
    $(this).each(function() {
      var $this = $(this);

      if ($this.hasClass("initialised")) {
        return;
      }

      $this.addClass("initialised");

      var renderTermRow = function() {
        $(".add-term-btn", $this).css("visibility", "hidden");
        $(".remove-term-btn", $this).css("visibility", "visible");

        var index = $(".term-row", $this).length;

        var template_data = {
          path: AS.quickTemplate($target_subrecord_list.data("name-path"), {index: index}),
          id_path: AS.quickTemplate($target_subrecord_list.data("id-path"), {index: index})
        };
        var $row = $(AS.renderTemplate("template_term", template_data));

        $target_subrecord_list.append($row);

        var typeahead_data = AS.AVAILABLE_TERMS;

        var itemDisplayString = function(item) {
          return  item.term + " ["+item.term_type+"]"
        };

        $(".terms-container .row-fluid:last :text:first", $this)
          .typeahead({
            source: function(query, process) {
              return typeahead_data;
            },
            matcher: function(item) {
              return item.term && itemDisplayString(item).toLowerCase().indexOf(this.query.toLowerCase()) >= 0;
            },
            sorter: function(items) {
              return items.sort(function(a, b) {
                return a.term > b.term;
              });
            },
            highlighter: function(item) {
              return $.proxy(Object.getPrototypeOf(this).highlighter, this)(itemDisplayString(item));
            },
            updater: function(item) {
              $("select", this.$element.parents(".row-fluid:first")).val(item.term_type);
              return item.term;
            }
          })
          .focus();
        $(".terms-container .row-fluid:last .add-term-btn", $this).css("visibility", "visible");
      };


      var removeTermRow = function() {
        $(this).parents(".subrecord-form-wrapper:first").remove();
        $(this).parents(".row-fluid:first").remove();
        renderTermsPreview();
        if ($(".terms-container .row-fluid", $this).length === 1) {
          $(".remove-term-btn", $this).css("visibility", "hidden");
        }
        $(".terms-container .row-fluid:last .add-term-btn", $this).css("visibility", "visible");
      };


      var renderTermsPreview = function() {
        var term_data = {
          terms: []
        };
        $(".terms-container .row-fluid", $this).each(function() {
          term_data.terms.push({
            term: $("input", $(this)).val(),
            term_type: $("select", $(this)).val()
          });
        });
        $(".terms-preview", $this).html(AS.renderTemplate("template_terms_preview", term_data));
      };

      $this.on("change keyup", ":input", renderTermsPreview);
      $this.on("click", ".add-term-btn", renderTermRow);
      $this.on("click", ".remove-term-btn", removeTermRow);

      var $target_subrecord_list = $(".terms-container .subrecord-form-list", $this);

      if ($(".term-row", $target_subrecord_list).length === 0) {
        renderTermRow();
        $(".terms-container .row-fluid:first .remove-term-btn", $this).css("visibility", "hidden");
      } else {
        renderTermsPreview();
        if ($(".term-row", $target_subrecord_list).length > 1) {
          $(".terms-container .row-fluid:not(:last) .add-term-btn", $this).css("visibility", "hidden");
        } else {
          $(".terms-container .row-fluid:first .remove-term-btn", $this).css("visibility", "hidden");
        }
      }

    });
  };


  $(document).ready(function() {
    $(document).ajaxComplete(function() {
      $("#terms.subrecord-form:not(.initialised)").init_terms_form();
    });

    $("#terms.subrecord-form:not(.initialised)").init_terms_form();
  });

});