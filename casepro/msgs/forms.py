from __future__ import unicode_literals

from django import forms
from django.utils.translation import ugettext_lazy as _

from casepro.contacts.models import Group
from casepro.rules.forms import FieldTestField
from casepro.rules.models import ContainsTest
from casepro.utils import parse_csv, normalize

from .models import Label, FAQ, Language


class LabelForm(forms.ModelForm):
    name = forms.CharField(label=_("Name"), max_length=128)

    description = forms.CharField(label=_("Description"), max_length=255, widget=forms.Textarea)

    is_synced = forms.BooleanField(
        label=_("Is synced"), required=False,
        help_text=_("Whether label should be kept synced with backend")
    )

    keywords = forms.CharField(
        label=_("Keywords"), widget=forms.Textarea, required=False,
        help_text=_("Match messages containing any of these words (comma separated)")
    )

    groups = forms.ModelMultipleChoiceField(
        queryset=Group.objects.none(), label=_("Groups"), required=False,
        help_text=_("Match messages from these groups (select none to include all groups)")
    )

    field_test = forms.CharField()  # switched below in __init__

    ignore_single_words = forms.BooleanField(
        label=_("Ignore single words"), required=False,
        help_text=_("Whether to ignore messages consisting of a single word")
    )

    def __init__(self, *args, **kwargs):
        org = kwargs.pop('org')
        is_create = kwargs.pop('is_create')

        super(LabelForm, self).__init__(*args, **kwargs)

        # don't let users change names of existing labels
        if not is_create:
            self.fields['name'].widget = forms.TextInput(attrs={'readonly': 'readonly'})

        self.fields['groups'].queryset = Group.get_all(org).order_by('name')

        self.fields['field_test'] = FieldTestField(
            org=org, label=_("Field criteria"), required=False,
            help_text=_("Match messages where contact field value is equal to any of these values (comma separated)")
        )

    def clean_name(self):
        name = self.cleaned_data['name'].strip()
        if name.lower() == 'flagged':
            raise forms.ValidationError(_("Reserved label name"))
        elif name.startswith('+') or name.startswith('-'):
            raise forms.ValidationError(_("Label name cannot start with + or -"))
        return name

    def clean_keywords(self):
        keywords = parse_csv(self.cleaned_data['keywords'])
        clean_keywords = []
        for keyword in keywords:
            clean_keyword = normalize(keyword)

            if not ContainsTest.is_valid_keyword(keyword):
                raise forms.ValidationError(_("Invalid keyword: %s") % keyword)

            clean_keywords.append(clean_keyword)

        return ', '.join(clean_keywords)

    class Meta:
        model = Label
        fields = ('name', 'description', 'is_synced', 'keywords', 'groups', 'field_test', 'ignore_single_words')


class FaqForm(forms.ModelForm):

    question = forms.CharField(label=_("Question"), max_length=140)
    answer = forms.CharField(label=_("Answer"), max_length=140)
    labels = forms.ModelMultipleChoiceField(queryset=Label.objects.filter())

    class Meta:
        model = FAQ
        fields = ('question', 'answer', 'labels')


class LanguageForm(forms.ModelForm):

    code = forms.CharField(label=_("6-digit Language Code (e.g. eng_UK)"), max_length=6)
    name = forms.CharField(label=_("Language Name (e.g. English"), max_length=100)
    location = forms.CharField(label=_("Language Location (e.g. United Kingdom"), max_length=100)

    class Meta:
        model = Language
        fields = ('code', 'name', 'location')
