$(function() {
  $("#courses th a, #courses .pagination a").live("click", function() {
    $.getScript(this.href);
    return false;
  });
  $("#course_search input").keyup(function() {
    $.get($("#course_search").attr("action"), $("#course_search").serialize(), null, "script");
    return false;
  });
});