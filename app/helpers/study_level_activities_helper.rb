# Copyright © 2011-2019 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

module StudyLevelActivitiesHelper

  def components_for_select(components)
    if components.empty?
      options_for_select(["This Service Has No Components"], disabled: "This Service Has No Components")
    else
      deleted_components = components.select{|c| c.deleted_at and c.selected } # deleted and selected
      visible_components = deleted_components + components.select{ |c| not c.deleted_at } # (deleted and selected) or not deleted
      options_from_collection_for_select( visible_components, 'id', 'component', selected: components.map{|c| c.id if c.selected}, disabled: deleted_components.map(&:id) )
    end
  end

  def sla_components_select(line_item_id, components)
    if components.any?
      select_tag "sla_#{line_item_id}_components", components_for_select(components), class: "sla_components selectpicker form-control", title: "Please Select", multiple: "", data:{container: "body", id: line_item_id, width: '150px', 'selected-text-format' => 'count>2'}
    else
      '-'
    end
  end

  def notes(notes)
    bullet_point = notes.count > 1 ? "\u2022 " : ""
    notes.map{ |note| bullet_point + note.created_at.strftime('%m/%d/%Y') + ", " + note.comment + ", " + Identity.find(note.identity_id).full_name }.join("<br>")
  end

  def documents(documents)
    bullet_point = documents.count > 1 ? "\u2022 " : ""
    documents.map{ |document| bullet_point + document.original_filename }.join("<br>")
  end

  def sla_options_buttons(line_item)
    options = raw(
      note_list_item({object: line_item, has_notes: line_item.notes.any?})+
      document_list_item({object: line_item, has_documents: line_item.documents.any?})+
      content_tag(:li, raw(
        content_tag(:button, raw(content_tag(:span, '', class: "glyphicon glyphicon-edit", aria: {hidden: "true"}))+' Edit Activity', type: 'button', class: 'btn btn-default form-control actions-button otf_edit'))
      )+
      content_tag(:li, raw(
        content_tag(:button, raw(content_tag(:span, '', class: "glyphicon glyphicon-remove", aria: {hidden: "true"}))+' Delete Activity', type: 'button', class: 'btn btn-default form-control actions-button otf_delete'))
      )
    )

    span = raw content_tag(:span, '', class: 'glyphicon glyphicon-triangle-bottom')
    button = raw content_tag(:button, raw(span), type: 'button', class: 'btn btn-default btn-sm dropdown-toggle form-control available-actions-button', 'data-toggle' => 'dropdown', 'aria-expanded' => 'false')
    ul = raw content_tag(:ul, options, class: 'dropdown-menu', role: 'menu')

    raw content_tag(:div, button + ul, class: 'btn-group overflow_webkit_button')
  end

  def fulfillments_drop_button(line_item)
    button = raw content_tag(:button, 'List', id: "list-#{line_item.id}", class: 'btn btn-success otf-fulfillment-list', title: 'List', type: "button", aria: {label: "List Fulfillments"}, data: {line_item_id: line_item.id})
  end

  def is_protocol_type_study?(protocol)
    protocol.protocol_type == 'Study'
  end

  def fulfillment_options_buttons(fulfillment)
    unless fulfillment.invoiced?
      options = raw(
        note_list_item({object: fulfillment, has_notes: fulfillment.notes.any?})+
        document_list_item({object: fulfillment, has_documents: fulfillment.documents.any?})+
        content_tag(:li, raw(
          content_tag(:button, raw(content_tag(:span, '', class: "glyphicon glyphicon-edit", aria: {hidden: "true"}))+' Edit Fulfillment', type: 'button', class: 'btn btn-default form-control actions-button otf_fulfillment_edit'))
        )+
        content_tag(:li, raw(
                      content_tag(:button, raw(content_tag(:span, '', class: "glyphicon glyphicon-remove", aria: {hidden: "true"}))+' Delete Fulfillment', type: 'button', class: 'btn btn-default form-control actions-button otf_fulfillment_delete', data: { id: fulfillment.id }))
        )
      )
    else
      options = raw(
        note_list_item({object: fulfillment, has_notes: fulfillment.notes.any?})+
        content_tag(:li, raw(
          content_tag(:button, raw(content_tag(:span, '', class: "glyphicon glyphicon-open-file", aria: {hidden: "true"}))+' Documents', type: 'button', class: 'btn btn-default form-control actions-button documents list', data: {documentable_id: fulfillment.id, documentable_type: "Fulfillment"}))
        )
      )
    end

    span = raw content_tag(:span, '', class: 'glyphicon glyphicon-triangle-bottom')
    button = raw content_tag(:button, raw(span), type: 'button', class: 'btn btn-default btn-sm dropdown-toggle form-control available-actions-button', 'data-toggle' => 'dropdown', 'aria-expanded' => 'false')
    ul = raw content_tag(:ul, options, class: 'dropdown-menu', role: 'menu')

    raw content_tag(:div, button + ul, class: 'btn-group')
  end

  def toggle_invoiced(fulfillment)
    if current_identity.billing_manager_protocols.include?(fulfillment.protocol)
      invoice_toggle_button(fulfillment)
    else
      invoice_read_only(fulfillment)
    end
  end

  def invoice_read_only(fulfillment)
    (fulfillment.invoiced? ? "Yes" : "No")
  end

  def fulfillment_grouper_formatter(fulfillment)
    fulfillment.fulfilled_at.strftime('%b %Y')
  end

  def fulfillment_components_formatter(components)
    components.map(&:component).join(', ')
  end

  def fulfillment_date_formatter(fulfillment)
    if fulfillment.klok_entry_id.present? # this was imported from klok
      content_tag(:span, format_date(fulfillment.fulfilled_at), class: 'fulfillment-date-for-klok-entry') +
      content_tag(:i, '', class: 'glyphicon glyphicon-time')
    else
      format_date(fulfillment.fulfilled_at)
    end
  end

  private

  def invoice_toggle_button(fulfillment)
    content_tag(:input, '', type: "checkbox", name: "invoiced", checked: fulfillment.invoiced?, data: {toggle: 'toggle', on: "Yes", off: "No", id: fulfillment.id}, disabled: fulfillment.invoiced?, class: 'invoice_toggle')
  end

  def credit_toggle_button(fulfillment)
    content_tag(:input, '', type: "checkbox", name: "credited", checked: fulfillment.credited?, data: {toggle: 'toggle', on: "Yes", off: "No", id: fulfillment.id}, disabled: fulfillment.credited?, class: 'credit_toggle')
  end

  def note_list_item(params)
    content_tag(:li, raw(
      content_tag(:button,
        raw(content_tag(:span, '', id: "#{params[:object].class.name.downcase}_#{params[:object].id}_notes", class: "glyphicon glyphicon-list-alt #{params[:has_notes] ? 'blue-glyphicon' : ''}", aria: {hidden: "true"}))+
        ' Notes', type: 'button', class: "btn btn-default form-control actions-button notes list", data: {notable_id: params[:object].id, notable_type: params[:object].class.name}))
    )
  end

  def document_list_item(params)
    content_tag(:li, raw(
      content_tag(:button,
        raw(content_tag(:span, '', id: "#{params[:object].class.name.downcase}_#{params[:object].id}_documents", class: "glyphicon glyphicon-open-file #{params[:has_documents] ? 'blue-glyphicon' : ''}", aria: {hidden: "true"}))+
        ' Documents', type: 'button', class: "btn btn-default form-control actions-button documents list", data: {documentable_id: params[:object].id, documentable_type: params[:object].class.name}))
    )
  end
end
