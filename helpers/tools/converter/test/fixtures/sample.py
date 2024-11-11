from typing import List, Optional, Protocol
from abc import ABC, abstractmethod

class LLMProtocol(Protocol):
    """Protocol for language models."""

    @abstractmethod
    async def generate(self, prompts: List[str], **kwargs) -> List[str]:
        """Generate completions for the prompts."""
        pass

    @property
    @abstractmethod
    def model_name(self) -> str:
        """Get the model name."""
        pass

class BaseChain(ABC):
    """Base class for chains."""

    memory: Optional[dict] = None
    verbose: bool = False

    @abstractmethod
    async def run(self, inputs: dict) -> dict:
        """Run the chain on the inputs."""
        pass

    def set_memory(self, memory: dict) -> None:
        """Set the memory for the chain."""
        self.memory = memory

class SimpleChain(BaseChain):
    """A simple implementation of a chain."""

    def __init__(self, llm: LLMProtocol):
        """Initialize the chain."""
        self.llm = llm
        self.history: List[str] = []

    async def run(self, inputs: dict) -> dict:
        """Execute the chain logic."""
        prompt = inputs.get("prompt", "")
        result = await self.llm.generate([prompt])
        self.history.append(result[0])
        return {"output": result[0]}
