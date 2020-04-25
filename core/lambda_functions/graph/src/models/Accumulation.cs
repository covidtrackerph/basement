namespace Graph.Models
{
    public class Accumulation<TAccumulate, TValue>
    {
        public TAccumulate Accumulator { get; set; }
        public TValue Value { get; set; }
    }
}