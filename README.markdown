Orchestrated Test Project
=========================

Orchestrated will soon be a Ruby Gem. For now we are using this little Rails application to develop and test the framework. If you run "rails s" and load the main page (/) you'll be creating a simple workflow. If you want to execute that thing you can either run "rake jobs:work" from the command line (to continually run steps) or go into "rails c" and run DJ.work(num=100) (to run a specified number of steps). You might also be interested in the specs. "rake spec" will run them all as expected.

To orchestrate (methods) on your own classes you simply call "acts_as_orchestrated" in the class definition like this:

  class StatementGenerator

    acts_as_orchestrated

    def generate(statement_id)
    ...
    end

    def render(statement_id)
    ...
    end

  end

After that you can orchestrate any method on such a class e.g.

  gen = StatementGenerator.new
  gen.orchestrate( orchestrate.generate(stmt_id) ).render(stmt_id)

The next time you process a delayed job, the :generate message will be delivered. The time after that, the :render message will be delivered.

What happened there? The pattern is:

1. create an orchestrated object (instantiate it)
2. call orchestrate on it: this returns an "orchestration"
3. send a message to the orchestration (returned in the second step)

Now the messages you can send in (3) are limited to the messages that your object can respond to. The message will be "remembered" by the framework and "replayed" (on a new instance of your object) somewhere on the network (later).

Not accidentally, this is similar to the way delayed_job's delay method works. Under the covers, orchestrated is consipring with delayed_job when it comes time to actually execute a workflow step. Before that time though, orchestrated keeps track of everything.

Prerequisites (Completion Expressions)
=========================================

Unlike delayed_job "delay", the orchestrated "orchestrated" method takes an optional parameter: the prerequisite. The prerequisite determines when your workflow step is ready to run.

The return value from "orchestrate" is itself a ready-to-use prerequisite. You saw this in the statement generation example above. The result of the first orchestrate call was sent as an argument to the second. In this way, the second workflow step was suspended until after the first one finished. You may have also noticed from that example that if you specify no prerequisite then the step will be ready to run immediately, as was the case for the "generate" call).

There are five kinds of prerequisite in all. Some of them are used for combining others. The prerequisites types, also known as "completion expressions" are:

1. OrchestrationCompletion—returned by "orchestrate", complete when its assocaited orchestration is complete
2. Complete—always complete
3. Incomplete—never complete
4. FirstCompletion—aggregates other completions: complete after the first one completes
5. LastCompletion—aggregates other completions: complete after all of them are complete

See the completion_spec for examples of how to combine these different prerequisite types into completion expressions.

Orchestration State
===================

An orchestration can be in one of six (6) states:

![Alt text](/path/to/img.jpg 'Orchestration States')

You'll never see an orchestration in the "new" state, it's for internal use in the framework. But all the others are interesting.

When you create a new orchestration that is waiting on a prerequisite that is not complete yet, the orchestration will be in the "waiting" state. Some time later, if that prerequisite completes, then your orchestration will become "ready". A "ready" orchestration is automatically queued to run by the framework (via delayed_job).

A "ready" orchestration will use delayed_job to delivery its (delayed) message. In the context of such a message delivery (inside your object method e.g. StatementGenerator#generate or StatementGenerator#render) you can rely on the ability to access the current Orchestration (context) object via the "orchestration" accessor.

After your workflow step executes, the orchestration moves into either the "succeeded" or "failed" state.

Next Steps
==========

TODO: currently it always moves to "succeeded", error handling will be added to move to "failed" on exception.
TODO: "cancelled" state is for future use: the idea is we want to add the ability to cancel orchestrations and have that cascade sensibly
TODO: package this thing into a Ruby Gem
