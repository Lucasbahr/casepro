from __future__ import unicode_literals

from casepro.cases.models import Case, CaseEvent, Contact
from casepro.dash_ext.tests import MockClientQuery
from casepro.test import BaseCasesTest
from datetime import datetime, timedelta
from django.utils import timezone
from mock import patch, call
from temba_client.v1.types import Message as TembaMessage
from .tasks import pull_messages


class TasksTest(BaseCasesTest):
    @patch('dash.orgs.models.TembaClient2.get_messages')
    @patch('dash.orgs.models.TembaClient1.label_messages')
    @patch('dash.orgs.models.TembaClient1.archive_messages')
    def test_pull_messages(self, mock_archive_messages, mock_label_messages, mock_get_messages):
        d1 = datetime(2014, 1, 1, 7, 0, tzinfo=timezone.utc)
        d2 = datetime(2014, 1, 1, 8, 0, tzinfo=timezone.utc)
        d3 = datetime(2014, 1, 1, 9, 0, tzinfo=timezone.utc)
        d4 = datetime(2014, 1, 1, 10, 0, tzinfo=timezone.utc)
        d5 = datetime(2014, 1, 1, 11, 0, tzinfo=timezone.utc)
        msg1 = TembaMessage.create(id=101, contact='C-001', text="What is aids?", created_on=d1)
        msg2 = TembaMessage.create(id=102, contact='C-002', text="Can I catch Hiv?", created_on=d2)
        msg3 = TembaMessage.create(id=103, contact='C-003', text="I think I'm pregnant", created_on=d3)
        msg4 = TembaMessage.create(id=104, contact='C-004', text="Php is amaze", created_on=d4)
        msg5 = TembaMessage.create(id=105, contact='C-005', text="Thanks for the pregnancy/HIV info", created_on=d5)
        mock_get_messages.side_effect = [
            MockClientQuery([msg1, msg2, msg3, msg4, msg5])
        ]

        # contact 5 has a case open that day
        d1 = datetime(2014, 1, 1, 5, 0, tzinfo=timezone.utc)
        with patch.object(timezone, 'now', return_value=d1):
            contact5 = Contact.get_or_create(self.unicef, 'C-005')
            case1 = Case.objects.create(org=self.unicef, contact=contact5,
                                        assignee=self.moh, message_id=99, message_on=d1)

        pull_messages(self.unicef.pk)

        task_state = self.unicef.get_task_state('message-pull')

        call_kwargs = mock_get_messages.call_args[1]
        self.assertEqual(call_kwargs['after'], task_state.started_on - timedelta(hours=1))
        self.assertEqual(call_kwargs['before'], task_state.started_on)

        mock_label_messages.assert_has_calls([
            call(messages=[msg1, msg2], label_uuid='L-001'),
            call(messages=[msg3], label_uuid='L-002')
        ], any_order=True)

        mock_archive_messages.assert_called_once_with(messages=[msg5])  # because contact has open case

        # check reply event was created for message 5
        events = case1.events.all()
        self.assertEqual(len(events), 1)
        self.assertEqual(events[0].event, CaseEvent.REPLY)
        self.assertEqual(events[0].created_on, d5)

        # check task result
        task_state = self.unicef.get_task_state('message-pull')
        self.assertEqual(task_state.get_last_results(), {'messages': 5, 'labelled': 3})
