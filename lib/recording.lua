-- Representation of a softcut recording, which may have looped.
-- To be used in conjunction with `idx_ndata` to track MIDI notes.
--

local C = {}

-- Create a new recording representation.
-- @param buffer_start    Where the loop starts in the buffer.
-- @param buffer_duration    Duration of the loop in the buffer.
-- @param idx_nd    Our `idx_ndata` structure with the MIDI note data.
--
function C.new(buffer_start, buffer_duration, idx_nd)
    local obj = {}
    setmetatable(obj, {__index = C})

    obj.buffer_start = buffer_start
    obj.buffer_duration = buffer_duration
    obj.buffer_end = buffer_start + buffer_duration

    obj.start_pos = buffer_start    -- Buffer position of the start of our recording

    obj.idx_nd = idx_nd

    return obj
end

-- Get the buffer position given the note data index.
-- @param i    Index of the note data.
--
function C:position(i)
    local start_time = self.idx_nd.time1
    local clock_gap = self.idx_nd:time(i) - start_time

    local pos = self.start_pos + clock_gap

    while pos > self.buffer_end do
        pos = pos - self.buffer_duration
    end

    return pos
end

-- Cut the recording to start from wherever the note data starts from.
-- The note data will be reindexed.
-- @return    The offset from the reindex.
--     Ie how many places the indices have moved back following the reindex.
--
function C:cut()
    local pos = self:position(self.idx_nd.first_index)

    self.start_pos = pos
    return self.idx_nd:reindex()
end

-- Where the loop starts in the buffer.
--
C.buffer_start = nil

-- Where the loop ends in the buffer.
--
C.buffer_end = nil

-- Duration of the loop in the buffer
--
C.buffer_duration = nil

return C
