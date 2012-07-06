  renderChoices = (question) ->
    list = $('<ol>')
    for choice, index in question.choices
      cls = if index in question.answer then 'chosen' else ""
      choice = rendermd(choice).replace(/<p>/g, '').replace(/<\/p>/g, '')
      choice = $('<li>').addClass(cls).append($('<div>').addClass('item_wrapper').append(choice))
      list.append(choice)
    return list

  renderCustomHTML = (question) ->
    raw_html = question.choices_template
    QuestionEditor.regex.matcher = if question.type == "CustomHTMLChooseAll" then QuestionEditor.regex.custom_choose_all else QuestionEditor.regex.custom_multiple_choice
    console.log QuestionEditor.regex.matcher
    return rendermd raw_html.replace QuestionEditor.regex.matcher, ($0, $1, $2, $3, $4, $5) ->
      str = ""
      if question.type == "CustomHTMLChooseAll"
        if $1.match QuestionEditor.regex.correct_choice
          str += c_checked_checkbox
        else
          str += c_empty_checkbox
      else if question.type == "CustomHTMLMultipleChoice"
        if $1.match QuestionEditor.regex.correct_choice
          str += c_checked_radiobox
        else
          str += c_empty_radiobox
      str += $3
      return str

  root.dataToOutput = (data, is_recursive, section_prefix) ->

    is_recursive = is_recursive || false
    section_prefix = section_prefix || ""
    section_counter = 0
    section_joint = if section_prefix then '.' else ''

    if data.type == "Assignment"
      question_container = $('<div>').addClass('questions')
      for element in data.element_list
        question_container.append(dataToOutput(element, is_recursive, section_prefix + section_joint + (++section_counter)))
      html = $('<div>').addClass('assignment_display').append(question_container)
      return html

    else if data.type in normal_question_types
      return renderHeaderAndText(data, is_recursive, section_prefix).append(renderChoices(data)).append(renderExplanation(data))

    else if data.type in custom_question_types
      return renderHeaderAndText(data, is_recursive, section_prefix).append(renderCustomHTML(data)).append(renderExplanation(data))

    else if data.type == "Group"
      html = renderHeaderAndText(data, is_recursive, section_prefix)
      if is_recursive
        for element in data.element_list
          html.append(dataToOutput(element, is_recursive, section_prefix + section_joint + (++section_counter)))
      html.append(renderExplanation(data))
      return html
    return ''

  
initQuickEditor = ->
    #
    # Structure of element_info:
    # {
    #   section_prefix
    #   section_counter
    #   id_choices
    #   edit_is_active
    #   edit_cache
    #   choice_type
    #   type
    # }
    #
    root.element_info = new Array()
    root.element_info[0] = {}
    root.element_info[0].section_prefix = ""
    root.element_info[0].section_counter = 0
    root.element_info[0].id_choices = 0
    root.element_info[0].type = "Assignment"
    root.id_elements = 0
    # TODO add groups and "to assignment back in when we add groups back in"
    #<a href='javascript:void(0)' class='button btn_add_question'>Add Question to Assignment</a>
    #<a href='javascript:void(0)' class='button btn_add_group'>Add Group to Assignment</a>
    root.prev_focus = ""
    $("#tabs_quick_editor").html """
      <div class="element_wrapper" id="element_0_wrapper">
        <div class="sub_elements" id="element_0_sub_elements"></div>
      </div>
      <div class='button_container_container' style='position: absolute; bottom: 0; width: 100%'>
        <div class='button_container'>
          <a href='javascript:void(0)' class='button btn_add_question'>Add Question</a>
        </div>
      </div>
    """

syncInput = (action) ->
    #$(".sync").bind 'change propertychange input keyup keydown keypress textInput', ->
    $(".sync").bind 'keyup', ->
      sync(getHeadId(this.id), this.id)

  sync = (element_id, input_id) ->
    if root.mathjaxTimeout
      window.clearTimeout(mathjaxTimeout)
      mathjaxTimeout = undefined
    delay = Math.min(root.elapsedTime + root.mathjaxDelay, maxDelay)
    root.renderId = element_id
    root.renderInputId = input_id
    root.mathjaxTimeout = window.setTimeout(makePreviewHtml, delay)

  makePreviewHtml = ->
    if root.mathjaxRunning
      return
    prevTime = new Date().getTime()
    element_id = root.renderId
    prefix = getPrefix element_id
    if root.renderInputId and root.renderInputId.match(/explanation/i) and $("#" + prefix + "preview > .question > .explanation").length
      $("#preview_buffer").html(rendermd($("#" + prefix + "input_explanation").val()))
      preview_id = prefix + "preview>.question>.explanation"
    else if root.renderInputId and root.renderInputId.match(/description/i) and $("#" + prefix + "preview > .question > .text").length
      $("#preview_buffer").html(rendermd($("#" + prefix + "input_description").val()))
      preview_id = prefix + "preview>.question>.text"
    else
      $("#preview_buffer").html(dataToOutput(inputToData(element_id))).prepend($("<div>").attr("id", prefix + "preview_label").addClass("preview_label").html("<h2>Live Preview</h2>"))
      preview_id = prefix + "preview"

    curTime = new Date().getTime()
    root.elapsedTiem = curTime - prevTime
    pushPreviewHtml(preview_id)

  pushPreviewHtml = (preview_id) ->
    element_id = root.renderId
    prefix = getPrefix element_id
    if root.MathJax
      prevTime = new Date().getTime()
      root.mathjaxRunning = true
      MathJax.Hub.Queue ["Typeset",MathJax.Hub, "preview_buffer"], ->
        root.mathjaxRunning = false
        curTime = new Date().getTime()
        root.mathjaxDelay = curTime - prevTime
        $("#" + preview_id).html($("#preview_buffer").html())
    else
      root.mathjaxDelay = false

    #container = $(document)
    #getScrollPt = ->
    #  $("#"+prefix+"edit").offset().top + container.height()/2
    #container.scrollTop(getScrollPt())
    

  getTime = ->
    (new Date).getTime() * 0.001

  focusPrevChoice = (element_id, choice_id) ->
    while choice_id - 1 >= 1 and not $(sprintf("#element_%d_input_choice_text_%d", element_id, choice_id - 1)).length
      choice_id -= 1
    if choice_id - 1 >= 1 and $(sprintf("#element_%d_input_choice_text_%d", element_id, choice_id - 1)).length
      $(sprintf("#element_%d_input_choice_text_%d", element_id, choice_id - 1)).focus()
      root.prev_focus = sprintf("#element_%d_input_choice_text_%d", element_id, choice_id - 1)
    else
      $(sprintf("#element_%d_input_explanation", element_id)).focus()
      root.prev_focus = ""

  focusNextChoice = (element_id, choice_id) ->
    id_choices = root.element_info[element_id].id_choices
    while choice_id + 1 <= id_choices and not $(sprintf("#element_%d_input_choice_text_%d", element_id, choice_id + 1)).length
      choice_id += 1
    if choice_id == id_choices
      addChoice(element_id)
    $(sprintf("#element_%d_input_choice_text_%d", element_id, choice_id + 1)).focus()
    root.prev_focus = sprintf("#element_%d_input_choice_text_%d", element_id, choice_id + 1)

  root.getPrefix = (element_id) ->
    "element_" + element_id +  "_"

  root.getTailId = (str) ->
    val = ""
    str.replace /(\d+)$/, ($0, $1) ->
      val = $1
    if val
      return parseInt(val)
    else
      return undefined

  root.getHeadId = (str) ->
    val = ""
    str.replace /^element_(\d+)/, ($0, $1) ->
      val = $1
    if val
      return parseInt(val)
    else
      return undefined

  init = ->
    if $("#assignment_form").length and $("#assignment_form").attr("page-type") == "edit"
      init_edit()
    else
      init_create_assignment()

    root.lastEditTime = getTime()
    root.renderTimerId = undefined

  rebuildEditor = (element, father_id) ->
    new_id = dataToInput(JSON.parse(unescapeHTML(element.children('.data').html())), father_id, false)
    element.children('.sub_data').children().each (index, element) ->
      rebuildEditor($(element), new_id)
    deactivateExcept -1

  init_edit = ->
    initQuickEditor()
    $(".hidden_data").children().each (index, element) ->
      rebuildEditor($(element), 0)
    bindEvents()
    $("#submit").click (event) ->
      event.preventDefault()
      raw_source = ""
      data = inputToData(0, true)
      raw_source = dataToSource data

      if not data.element_list or not data.element_list.length
        console.log "The assignment is empty!"
      else
        assignment_id = $("#assignment_form").attr("data-assignment")
        $.ajax {
          type: "PUT",
          url: "/admin/assignments/" + assignment_id + "/",
          data: {
            assignment: {
              data: JSON.stringify(data),
              raw_source: raw_source,
              title: $("#assignment_title").val(),
            },
          },
          dataType: "json",
        }
      console.log "submitted"


  init_create_assignment = ->

    root.current_tab = "quick_edit"
    initQuickEditor()
    $("#tabs_source").hide()

    $("textarea#source").bind 'change propertychange input keyup keydown keypress textInput', ->
      $("#source_preview").html(dataToOutput(sourceToData($("textarea#source").val()), true))
      if root.MathJax
        MathJax.Hub.Queue(["Typeset",MathJax.Hub])

    $("li#tab_quick_editor").click ->
      if root.current_tab != "quick_edit"
        root.current_tab = "quick_edit"
        $(this).addClass('selected')
        $("li#tab_source").removeClass('selected')
        $("#tabs_source").hide()
        $("#tabs_quick_editor").show()
        console.log "switching from source to quick editing"
        initQuickEditor()
        dataToInput(sourceToData($("textarea#source").val()), 0, true)
        bindEvents()

    $("li#tab_source").click ->
      if root.current_tab != "source"
        root.current_tab = "source"
        $(this).addClass('selected')
        $("li#tab_quick_editor").removeClass('selected')
        $("#tabs_source").show()
        $("#tabs_quick_editor").hide()
        console.log "switching from quick editing to source"
        $("textarea#source").val(document.getElementById("source").innerHTML = dataToSource(inputToData(0, true)).toString())
        $("#source_preview").html(dataToOutput(sourceToData($("textarea#source").val()), true))
        if root.MathJax
          MathJax.Hub.Queue(["Typeset",MathJax.Hub])

    addError = (errorMsg) ->
      if $("#error_list").length
        console.log "here"
        $("#error_list").append("<li>#{errorMsg}</li>")
      else
        errorDiv = $('<div>').attr('id', "errors").addClass("message")
        errorDiv.html("<ul id='error_list'><li>#{errorMsg}</li></ul>")
        $("#new_assignment").before(errorDiv)
      window.scrollTo 0, 0

    $("#submit").click (event) ->
      $(this).attr('disabled', 'disabled')
      $('#errors').remove()
      if $("#assignment_title").val().strip() == ""
        $("#assignment_title").wrap($('<div>').addClass('field_with_errors'))
        addError("Please give your assignment a name.")
        $(this).removeAttr('disabled')
        $("#assignment_title").focus()
        return false
      else
        if $("#assignment_title").parent(".field_with_errors").length
          $("#assignment_title").unwrap()
      
      event.preventDefault()
      raw_source = ""
      data = {}
      if root.current_tab == "source"
        console.log "currently in source"
        raw_source = $("textarea#source").val()
        data = sourceToData raw_source
      else
        console.log "currently in quick editor"
        data = inputToData(0, true)
        raw_source = dataToSource data

      console.log 'source'
      console.log raw_source
      console.log 'data'
      console.log JSON.stringify data

      if not data.element_list or not data.element_list.length
        addError("Please add some questions before submitting your assignment.")
        $(this).removeAttr('disabled')
        return false
      else if data.error_list
        for error in data.error_list
          addError error
        $(this).removeAttr('disabled')
        return false
      else
        path = $('#new_assignment').attr('action')
        $.ajax {
          type: "POST",
          url: path,
          data: {
            assignment: {
              data: JSON.stringify(data),
              raw_source: raw_source,
              title: $("#assignment_title").val(),
            },
          },
          dataType: "json",
          success: (data, textStatus) ->
            window.location.href = data.redirectURL
          error: (xhr, textStatus) ->
            console.log xhr
            console.log textStatus
            addError(xhr.responseText)
            $(this).removeAttr('disabled')
        }

    bindEvents()

  deleteChoice = (element_id, choice_id) ->
    $(sprintf("#element_%d_choice_wrapper_%d", element_id, choice_id)).remove()
    sync(element_id)

  root.preserveHtml = (element_id) ->
    console.log 'preserve'
    prefix = getPrefix element_id
    $("#" + prefix + "input_score").attr("value", $("#" + prefix + "input_score").val())
    if $("#" + prefix + "input_description").length
      document.getElementById(prefix + "input_description").innerHTML = $("textarea#" + prefix + "input_description").val()
    if $("#" + prefix + "input_explanation").length
      document.getElementById(prefix + "input_explanation").innerHTML = $("textarea#" + prefix + "input_explanation").val()
    if $("#" + prefix + "input_custom_html").length
      document.getElementById(prefix + "input_custom_html").innerHTML = $("textarea#" + prefix + "input_custom_html").val()
    $("." + prefix + "input_choice_text").each (index, element) ->
      console.log element.id + ":" + $(element).val()
      element.innerHTML = $(element).val()
    $("." + prefix + "input_choice").each (index, element) ->
      $(element).attr("checked", $(element).attr("checked"))

  root.doneEdit = (element_id) ->
    if not root.element_info[element_id].edit_is_active
      return

    prefix = getPrefix element_id
    preserveHtml element_id
    sync element_id
    root.element_info[element_id].edit_cache = $(sprintf("#element_%d", element_id)).html()

    $("#" + prefix + "edit").remove()
    $("#" + prefix + "preview_label").remove()
    $(sprintf("#element_%d", element_id)).append """
      <a href='javascript:void(0)' class='button btn_edit' id='element_{eid}_btn_edit'>
        Edit
      </a>
    """.replace(/{eid}/, element_id)
    bindEvents()
    root.element_info[element_id].edit_is_active = false
    console.log 'done'

  root.restoreEdit = (element_id) ->
    if root.element_info[element_id].edit_is_active
      return
    $(sprintf("#element_%d", element_id)).html root.element_info[element_id].edit_cache
    $(sprintf("#element_%d_edit", element_id)).addClass('active')
    # fix section id in editor if changed during preview
    # section div has header tag in it; get header tag and replace its text
    section_element_header = $("#" + getPrefix(element_id) + "section").children()
    if section_element_header.length
      section_element_header.html(section_element_header.html().replace(QuestionEditor.regex.section, root.element_info[element_id].section_prefix))
    bindEvents()
    root.element_info[element_id].edit_is_active = true
    sync(element_id)

  bindEvents = ->

    $(".sync").unbind()

    $(".select_type").unbind().change ->
      val = $(this).val()
      element_id = getHeadId this.id
      prefix = getPrefix element_id
      root.element_info[element_id].type = val
      if val in normal_question_types
        if $("#" + prefix + "custom_html_wrapper").length
          $("#" + prefix + "custom_html_wrapper").parent('.choices_wrapper').before("""
            <input class="hiddentab hiddentab_explanation" id="element_{eid}_hiddentab_explanation">
          """.replace(/{eid}/g, element_id))
          $("#" + prefix + "custom_html_wrapper").replaceWith("""
            <div class="choices_label"> Choices </div>
            <div class='input_choices' id='element_{eid}_input_choices'></div>
            <div class='button_container' id='element_{eid}_add_button_container'>
              <a href='javascript:void(0)' class='button btn_add_choice' id='element_{eid}_btn_add_choice'>
                Add choice
              </a>
            </div>
          """.replace(/{eid}/g, element_id))
          choice_id = addChoice(element_id)
        if val == "MultipleChoiceQuestion"
          root.element_info[element_id].choice_type = "radio"
          first_id = 0
          $("." + prefix + "input_choice").each (index, element) ->
            eid = getHeadId element.id
            cid = getTailId element.id
            first_id = first_id || cid
            $(element).replaceWith($("""<input type="radio" class="input_choice element_{eid}_input_choice sync sync_{eid}" id="element_{eid}_input_choice_{cid}" name="element_{eid}_input_choice" />""".replace(/{eid}/g, eid).replace(/{cid}/g, cid)).attr("value", $(element).val()))
          $("#" + getPrefix(element_id) + "input_choice_" + first_id).attr("checked", "checked")
        else if val == "ChooseAllQuestion"
          root.element_info[element_id].choice_type = "checkbox"
          $("." + prefix + "input_choice").each (index, element) ->
            eid = getHeadId element.id
            cid = getTailId element.id
            $(element).replaceWith($("""<input type="checkbox" class="input_choice element_{eid}_input_choice sync sync_{eid}" id="element_{eid}_input_choice_{cid}" name="element_{eid}_input_choice" />""".replace(/{eid}/g, eid).replace(/{cid}/g, cid)).attr("value", $(element).val()))
      else if val in custom_question_types
        $("#" + prefix + "hiddentab_explanation").remove()
        $(".choices_label").remove()
        $("#" + prefix + "add_button_container").remove()
        $("#" + prefix + "input_choices").replaceWith("""
          <div class='custom_html_wrapper' id='element_{eid}_custom_html_wrapper'>
            <label class='title_custom_html'>
              Custom Layout for Choices
            </label>
            <textarea class='sync sync_{eid}' id='element_{eid}_input_custom_html' rows='4'></textarea>
          </div>
        """.replace(/{eid}/g, element_id))
        root.element_info[element_id].id_choices = 0

      bindEvents()

    $(".btn_add_question").unbind().click ->
      element_id = getHeadId this.id
      new_id = addElement(config.default_type, element_id)
      choice_id = addChoice(new_id)
      prefix = getPrefix new_id
      $("#" + prefix + "input_choice_" + choice_id).attr("checked", "checked")


    $(".btn_add_group").unbind().click ->
      element_id = getHeadId this.id
      addElement("Group", element_id)

    $(".btn_edit").unbind().click ->
      element_id = getHeadId this.id
      restoreEdit element_id
      deactivateExcept element_id

    $(".btn_done").unbind().click ->
      element_id = getHeadId this.id
      doneEdit element_id

    $(".btn_add_choice").unbind().click ->
      element_id = getHeadId this.id
      addChoice(element_id)

    $(".hiddentab_explanation").unbind().focus ->

      element_id = getHeadId this.id
      id_choices = root.element_info[element_id].id_choices

      if root.prev_focus
        root.prev_focus = ""
        $(sprintf("#element_%d_input_explanation", element_id)).focus()
      else
        focusNextChoice(element_id, 0)

    $("*").focus ->
      root.prev_focus = ""

    $(".input_choice_text").focus ->
      root.prev_focus = this.id

    $(".delete_choice").unbind().focus( ->
      element_id = getHeadId this.id
      choice_id = getTailId this.id
      if root.prev_focus
        if getTailId(root.prev_focus) == choice_id
          focusNextChoice(element_id, choice_id)
        else
          focusPrevChoice(element_id, getTailId(root.prev_focus))
      else
        focusNextChoice(element_id, choice_id)

    ).click ->
      element_id = getHeadId this.id
      choice_id = getTailId this.id
      deleteChoice element_id, choice_id

    $(".input_choice").unbind().focus ->

      element_id = getHeadId this.id
      choice_id = getTailId this.id

      if root.prev_focus
        if getTailId(root.prev_focus) == choice_id
          focusPrevChoice(element_id, choice_id)
        else
          focusNextChoice(element_id, getTailId(root.prev_focus))
      else
        focusPrevChoice(element_id, choice_id)
      

    $(".btn_delete").unbind().click ->

      element_id = getHeadId this.id
      prefix = getPrefix element_id
      console.log element_id

      $("#" + prefix + "wrapper").remove()
      fixSections()

    syncInput()

  # return choice id
  addChoice = (element_id, value="") ->

    choice_id = ++root.element_info[element_id].id_choices

    choice_type = root.element_info[element_id].choice_type
    
    choice_template = """
      <div class="choice_wrapper element_{eid}_choice_wrapper" id="element_{eid}_choice_wrapper_{cid}">
        <input type="{type}" class="input_choice element_{eid}_input_choice sync sync_{eid}" id="element_{eid}_input_choice_{cid}" name="element_{eid}_input_choice"/>
        <textarea class="input_choice_text element_{eid}_input_choice_text sync sync_{eid}" id="element_{eid}_input_choice_text_{cid}" name="element_{eid}_input_choice_text_{cid}">#{value}</textarea>
        <a class="delete_choice element_{eid}_delete_choice" id="element_{eid}_delete_choice_{cid}" href="javascript:void(0)"><img src='/assets/icons/cross.png'/></a>
      </div>
    """
    $(sprintf("#element_%d_input_choices", element_id)).append(choice_template.replace(/{eid}/g, element_id).replace(/{cid}/g, choice_id).replace(/{type}/g, choice_type))

    $(sprintf("#element_%d_input_choice_text_%d", element_id, choice_id)).focus()
    
    bindEvents()

    return choice_id

  # element_id: id of the father element
  # returns id of the newly created element
  addElement = (type, element_id) ->
    type = type || config.default_type

    element_id = element_id || 0

    section_prefix = root.element_info[element_id].section_prefix
    section_counter = ++root.element_info[element_id].section_counter
    section_joint = if section_prefix then '.' else ''

    section_id = section_prefix + section_joint + section_counter

    c = ++root.id_elements

    root.element_info[c] = {}
    root.element_info[c].type = type
    root.element_info[c].edit_is_active = true
    root.element_info[c].section_prefix = section_id
    root.element_info[c].section_counter = 0
    root.element_info[c].id_choices = 0
    switch type
      when "MultipleChoiceQuestion"
        root.element_info[c].choice_type = "radio"
      when "ChooseAllQuestion"
        root.element_info[c].choice_type = "checkbox"
      else
        root.element_info[c].choice_type = "checkbox"

    template_question = """ 
      <div class='element_wrapper' id='element_{eid}_wrapper'>
        <div id='element_{eid}' class='element'>
          <div class='preview quick_preview' id='element_{eid}_preview'>
          </div>
          <div id='element_{eid}_edit' class='element_edit active'>
            <div class='section' id='element_{eid}_section'>
              <h2> Editor </h2>
            </div>
            <label for='element_{eid}_select_type'>Question Type</label>
            <select class="select_type sync sync_{eid}" id="element_{eid}_select_type">
              <option value='MultipleChoiceQuestion'>
                Multiple choice
              </option>
              <option value='ChooseAllQuestion'>
                Select all that apply
              </option>
              <optgroup label="Advanced">
                <option value='CustomHTMLMultipleChoice'>
                  Multiple choice with custom layout
                </option>
                <option value='CustomHTMLChooseAll'>
                  Select all with custom layout
                </option>
              </optgroup>
            </select>
            <label for='element_{eid}_input_score' class='points'>Points</label>
            <input id='element_{eid}_input_score' class='points score sync sync_{eid}' value='1'>
            <br/>
            <div class='text_wrapper'>
            <label class='title_description' for='element_{eid}_input_description'>Text</label>
            <textarea class='sync sync_{eid}' id='element_{eid}_input_description' rows='3'></textarea>
            </div>
            <div class='explanation_wrapper'>
            <label class='title_explanation' for='element_{eid}_input_explanation'>Explanation</label>
            <textarea class='sync sync_{eid}' id='element_{eid}_input_explanation' rows='3'></textarea>
            </div>
            %s
            
          </div>
        </div>
    """

    template_normal_question = sprintf template_question, """
      <input class='hiddentab hiddentab_explanation' id='element_{eid}_hiddentab_explanation'>
      <div class='choices_wrapper'>
        <div class="choices_label"> Choices </div>
        <div class='input_choices' id='element_{eid}_input_choices'></div>
        <div class='button_container' id='element_{eid}_add_button_container'>
          <a href='javascript:void(0)' class='button btn_add_choice' id='element_{eid}_btn_add_choice'>
            Add choice
          </a>
        </div>
      </div>
      <div class='button_container'>
        <a href='javascript:void(0)' class='button dangerous btn_delete' id='element_{eid}_btn_delete'>
          Delete Question
        </a>
        <a href='javascript:void(0)' class='button good btn_done' id='element_{eid}_btn_done'>
          Done
        </a>
      </div>
    """

    template_custom_question = sprintf template_question, """
      <div class='choices_wrapper'>
        <div class='custom_html_wrapper' id='element_{eid}_custom_html_wrapper'>
          <label class='title_custom_html'>
            Custom Layout for Choices
          </label>
          <textarea class='sync sync_{eid}' id='element_{eid}_input_custom_html' rows='4'></textarea>
        </div>
      </div>
      <div class='button_container'>
        <a href='javascript:void(0)' class='dangerous button btn_delete' id='element_{eid}_btn_delete'>
          Delete Question
        </a>
        <a href='javascript:void(0)' class='button good btn_done' id='element_{eid}_btn_done'>
          Done
        </a>
      </div>
    """

    template_group = """ 
      <div class='element_wrapper' id='element_{eid}_wrapper'>
        <div id='element_{eid}' class='element'>
          <div class='preview quick_preview' id='element_{eid}_preview'>
          </div>
          <div id='element_{eid}_edit' class='element_edit active'>
            <div class='section' id='element_{eid}_section'>
              <h2> Editor </h2>
            </div>
            <div class='question_group_points'>
              <label for='element_{eid}_input_score' class='points'>Points</label>
              <input id='element_{eid}_input_score' class='points sync sync_{eid}' value='1'>
            </div>
            <div class='text_wrapper'>
              <label class='title_description' for='element_{eid}_input_description'>Text</label>
              <textarea class='sync sync_{eid}' id='element_{eid}_input_description' rows='3'></textarea>
            </div>
            <div class='explanation_wrapper'>
              <label class='title_explanation' for='element_{eid}_input_explanation'>Explanation</label>
              <textarea class='sync sync_{eid}' id='element_{eid}_input_explanation' rows='3'></textarea>
            </div>

            <div class='button_container'>
              <a href='javascript:void(0)' class='button dangerous btn_delete' id='element_{eid}_btn_delete'>
                Delete Group
              </a>
              <a href='javascript:void(0)' class='button good btn_done' id='element_{eid}_btn_done'>
                Done
              </a>
            </div>

          </div>
        </div>
        <div class='sub_elements' id='element_{eid}_sub_elements'>
        </div>

        <div class='button_container'>
          <a class='button btn_add_question' id='element_{eid}_btn_add_question' href='javascript:void(0)'>
            Add Question{postfix}
          </a>
          <a class='button btn_add_group' id='element_{eid}_btn_add_group' href='javascript:void(0)'>
            Add Group{postfix}
          </a>
        </div>
      </div>
    """

    insert_area = $("#" + getPrefix(element_id) + "sub_elements")

    postfix = ' To Group ' + section_id

    if type in normal_question_types
      insert_area.append(template_normal_question.replace(/{eid}/g, c).replace(/{sid}/g, section_id))
      $(sprintf("#element_%d_input_description", c)).focus()

    else if type in custom_question_types
      insert_area.append(template_custom_question.replace(/{eid}/g, c).replace(/{sid}/g, section_id))
      $(sprintf("#element_%d_input_description", c)).focus()
      
    else if type == "Group"
      insert_area.append(template_group.replace(/{eid}/g, c).replace(/{sid}/g, section_id).replace(/{postfix}/g, postfix))
      $(sprintf("#element_%d_input_description", c)).focus()

    deactivateExcept c

    bindEvents()

    sync(c)

    return c

  deactivateExcept = (element_id) ->
    $(".element").each (index, element) ->
        if getHeadId(element.id) != element_id
          doneEdit getHeadId element.id


  # element_id: id of the father element
  root.dataToInput = (data, element_id, is_recursive) ->
    element_id = element_id || 0
    console.log data

    if is_recursive and data.type in ["Assignment"]
      for element in data.element_list
        dataToInput(element, element_id, is_recursive)
      deactivateExcept -1
      return 0

    else if data.type in ["Group"]
      c = addElement(data.type, element_id)
      prefix = getPrefix c
      
      score = data["score"] || 1
      description = data["description"] || ""
      explanation = data["explanation"] || ""

      $("#" + prefix + "input_score").val(score)
      $("#" + prefix + "input_description").val(document.getElementById(prefix + "input_description").innerHTML = description)
      $("#" + prefix + "input_explanation").val(document.getElementById(prefix + "input_explanation").innerHTML = explanation)

      if is_recursive
        for element in data.element_list
          dataToInput element, c, is_recursive

      preserveHtml(c)
      sync(c)
      return c


    else if data.type in normal_question_types
      c = addElement(data.type, element_id)
      prefix = getPrefix c
      
      type = data["type"]
      score = data["score"] || 1
      description = data["description"] || ""
      explanation = data["explanation"] || ""

      if type == "MultipleChoiceQuestion"
        root.element_info[c].choice_type = "radio"
      else if type == "ChooseAllQuestion"
        root.element_info[c].choice_type = "checkbox"

      $("#" + prefix + "select_type").val(type)
      $("#" + prefix + "input_score").val(score)
      $("#" + prefix + "input_description").val(document.getElementById(prefix + "input_description").innerHTML = description)
      $("#" + prefix + "input_explanation").val(document.getElementById(prefix + "input_explanation").innerHTML = explanation)

      cnt_added_choice = 0
      for label in data["choices"]
        cnt_added_choice += 1
        choice_id = addChoice(c)
        if (choice_id - 1) in data["answer"]
          $("#" + prefix + "input_choice_" + choice_id).attr("checked", true)
        $("#" + prefix + "input_choice_text_" + choice_id).val(document.getElementById(prefix + "input_choice_text_" + choice_id).innerHTML = label)

      if not cnt_added_choice
        addChoice(c)

      preserveHtml(c)
      sync(c)
      return c

    else if data.type in custom_question_types
      c = addElement(data.type, element_id)
      prefix = getPrefix c
      
      type = data["type"]
      score = data["score"] || 1
      description = data["description"] || ""
      explanation = data["explanation"] || ""
      custom_html = data["choices_template"] || ""

      root.element_info[c].choice_type = "checkbox"

      $("#" + prefix + "select_type").val(type)
      $("#" + prefix + "input_score").val(score)
      $("#" + prefix + "input_description").val(document.getElementById(prefix + "input_description").innerHTML = description)
      $("#" + prefix + "input_explanation").val(document.getElementById(prefix + "input_explanation").innerHTML = explanation)
      $("#" + prefix + "input_custom_html").val(document.getElementById(prefix + "input_custom_html").innerHTML = custom_html)

      preserveHtml(c)
      sync(c)
      return c





  root.inputToData = (element_id, is_recursive) -> # TODO add database id
    # This function converts the input fields into an object, denoting the question (json)

    is_active = root.element_info[element_id].edit_is_active
    if not is_active
      root.restoreEdit element_id
    else if is_recursive
      preserveHtml element_id

    prefix = getPrefix element_id
    is_recursive = is_recursive || false

    error_list = []

    if root.element_info[element_id].type in question_types
      # deal with question first
      description = $("#" + prefix + "input_description").val() || ""
      explanation = $("#" + prefix + "input_explanation").val() || ""
      score = $("#" + prefix + "input_score").val()
      if root.element_info[element_id].type in normal_question_types
        choices = new Array()
        answer = new Array()
        $("." + prefix + "choice_wrapper").each (index, element) ->
          choice = $(element).children(".input_choice_text").val()
          if is_recursive
            console.log "choice: " + choice
          if not (config.ignore_empty_choices and choice.match QuestionEditor.regex.blank_line)
            choices.push choice
            correct = $(element).children(".input_choice").attr("checked")
            console.log "iscorrect: " + correct
            if correct
              console.log choice.strip()
              console.log root.element_info[element_id].type
              answer.push(choices.length - 1)
          else if $(element).children(".input_choice").attr("checked") and
          root.element_info[element_id].type == "MultipleChoiceQuestion" and
          not choice.strip()
              error_list.push "Question " + root.element_info[element_id].section_prefix + ": Multiple choice question must have an answer selected."
        if is_recursive
          console.log "choices for " + prefix + ": " + choices
        element = {
          type        : root.element_info[element_id].type,
          description : description,
          choices     : choices,
          answer      : answer,
          section_id  : root.element_info[element_id].section_prefix,
          score       : score,
          explanation : explanation,
          id: element_id, # TODO
        }
        if not answer.length
          error_list.push makeQuestionError(element_id, "Need to have at least one answer with nonblank text.")
      else
        choices_template = $("textarea#" + prefix + "input_custom_html").val() || ""
        element = {
          type        : root.element_info[element_id].type,
          description : description,
          section_id  : root.element_info[element_id].section_prefix,
          score       : score,
          explanation : explanation,
          choices_template: choices_template,
          answer: root.getAnswerFromSource(choices_template, root.element_info[element_id].type),
          id: element_id, # TODO
        }
    else if root.element_info[element_id].type in ["Group"]
      description = $("textarea#" + prefix + "input_description").val() || ""
      explanation = $("textarea#" + prefix + "input_explanation").val() || ""
      score = $("#" + prefix + "input_score").val()
      element_list = []
      
      if is_recursive
        $("#" + prefix + "sub_elements").children().each (index, element) ->
          new_element = root.inputToData(getHeadId(element.id), is_recursive)
          if new_element.error_list
            error_list = error_list.concat(new_element.error_list).unique()
          element_list.push new_element

      element = {
        type         : root.element_info[element_id].type,
        description  : description,
        explanation  : explanation,
        section_id   : root.element_info[element_id].section_prefix,
        score        : score,
        element_list : element_list,
        id: element_id,
      }
    else if root.element_info[element_id].type in ["Assignment"]
      element_list = []
      
      if is_recursive
        $("#" + prefix + "sub_elements").children().each (index, element) ->
          new_element = root.inputToData(getHeadId(element.id), is_recursive)
          if new_element.error_list
            error_list = error_list.concat(new_element.error_list).unique()
          element_list.push new_element

      element = {
        type         : root.element_info[element_id].type,
        element_list : element_list,
      }

    if error_list.length
      element["error_list"] = error_list
    if not is_active
      root.doneEdit element_id
    return element

  fixSections = (element_id, section_prefix) ->
    element_id = element_id || 0
    section_prefix = section_prefix || ""
    section_joint = if section_prefix then '.' else ''
    section_counter = 0
    prefix = getPrefix element_id
    
    if root.element_info[element_id].edit_is_active
      # fix section id in editor
      section_element = $("#" + prefix + "section")
      if section_element.length
        section_element.html(section_element.html().replace(QuestionEditor.regex.section, section_prefix))
    else
      # fix section id in preview
      if root.element_info[element_id].type == "Group"
        section_element = $("#" + prefix + "preview").children(".question_group").children(".header")
        if section_element.length
          section_element.html(section_element.html().replace(QuestionEditor.regex.section, section_prefix))
      else if root.element_info[element_id].type in question_types
        section_element = $("#" + prefix + "preview").children(".question").children(".header")
        if section_element.length
          section_element.html(section_element.html().replace(QuestionEditor.regex.section, section_prefix))

    

    $("#" + prefix + "sub_elements").children().each (index, element) ->
      fixSections(getHeadId(element.id), section_prefix + section_joint + (++section_counter))

    root.element_info[element_id].section_prefix = section_prefix
    root.element_info[element_id].section_counter = section_counter
  
  makeQuestionError = (element_id, msg) ->
    "Question " + root.element_info[element_id].section_prefix + ": " + msg
  init()

String::strip = -> if String::trim? then @trim() else @replace /^\s+|\s+$/g, ""
  unescapeHTML = (html) -> $("<div />").html(html).text()

  showdown_converter = new Showdown.converter()

  rendermd = (text) ->
    return showdown_converter.makeHtml(text)
  #
  # Scheme:
  # Input <---> JSON (Data) <---> Source Code
  #               |
  #               |
  #               |
  #              \|/
  #               -
  #             Output
  #
  # Structure of data:
  # All data have a "type" field which is case-insensitive
  #
  # Type Assignment:
  #     element_list: { all groups / questions of the assignment }
  #
  # Type Group:
  #     element_list: { all subgroups / subquestions },
  #     score: { score of this group },
  #     description: { description of the group },
  #     section_id: { section number of the group },
  #
  # Type (Question):
  #     type: { ChooseAllQuestion || MultipleChoiceQuestion || CustomHTMLChooseAll },
  #     description: { description of the question },
  #     explanation: { explanation of the question },
  #     choices: { choices of the question; only have this field if type != CustomHTMLChooseAll },
  #     answer: { answer of the question; only have this field if type != CustomHTMLChooseAll },
  #     choices_template { choice template of the question; only have this field if type == CustomHTMLChooseAll },
  #     section_id: { section number of the question },
  #
  #

  Array.prototype.unique = ->
      a = this.concat()
      for i in [0..a.length] by 1
        for j in [i+1..a.length] by 1
          if a[i] == a[j]
            a.splice(j, 1)
      return a

  # configurations

  root.maxDelay = 3000
  
  c_empty_checkbox = "&#9744;"
  c_checked_checkbox = "&#9745;"
  c_empty_radiobox = "&#9675;" # what's for this?
  c_checked_radiobox = "&#9679;"
