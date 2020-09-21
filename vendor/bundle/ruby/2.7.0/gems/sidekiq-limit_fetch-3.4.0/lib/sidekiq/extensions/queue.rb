module Sidekiq
  class Queue
    extend LimitFetch::Instances, Forwardable
    attr_reader :rname

    def_delegators :lock,
      :limit,         :limit=,         :limit_changed?,
      :process_limit, :process_limit=,
      :acquire,       :release,
      :pause,         :pause_for_ms,   :unpause,
      :block,         :unblock,
      :paused?,       :blocking?,
      :unblocked,     :block_except,
      :probed,        :busy,
      :increase_busy, :decrease_busy,
      :local_busy?,   :explain,
      :remove_locks_except!

    def lock
      @lock ||= LimitFetch::Global::Semaphore.new name
    end
  end
end
