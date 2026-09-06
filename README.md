# CPG-on-LIF_neurons

## 🧠 Neurophyx CPG

**RTL implementation of a Central Pattern Generator (CPG) based on Leaky Integrate-and-Fire (LIF) neurons.**

---

## 📖 About the Project

A Central Pattern Generator (CPG) is a neural network capable of generating rhythmic signals without external clock pulses. Such generators are fundamental to movement control in biological organisms (walking, breathing, swimming).

This project implements a CPG at the hardware level (RTL) using the **LIF neuron model**, which describes neuron behavior as the accumulation of membrane potential to a threshold value, followed by a reset (spike).

---

## ⚙️ Model Parameters

| Parameter | Description |
|-----------|-------------|
| `SPIKE_VALUE_A` | Spike weight of neuron A |
| `SPIKE_VALUE_B` | Spike weight of neuron B |
| `POTENTIAL_CAPACITY_A` | Threshold potential value for neuron A |
| `POTENTIAL_CAPACITY_B` | Threshold potential value for neuron B |
| `INHIBITION_VALUE_B` | Inhibitory potential coming from neuron B |
| `BACKGROUND_CURRENT` | Background current that constantly charges the neuron |
| `LEAKAGE_VALUE_A` | Potential leakage rate for neuron A |
| `LEAKAGE_VALUE_B` | Potential leakage rate for neuron B |
| `REFRACTORY_PERIOD_TIME_A` | Refractory period duration for neuron A |
| `REFRACTORY_PERIOD_TIME_B` | Refractory period duration for neuron B |

---

## 🔬 Principle of Operation

### 1. Neuron Charging

The neuron's potential increases due to several sources:

- **`start_impulse`** — an external start pulse that initiates generation
- **`BACKGROUND_CURRENT`** — a constant background current that continuously charges the neuron
- **`spike_from_A`** — a spike coming from neuron A (weight is regulated by the `SPIKE_VALUE_A` parameter)

When the potential reaches the threshold value (`POTENTIAL_CAPACITY`), the neuron fires a spike and resets its potential.

---

### 2. Discharge (Leakage)

To prevent infinite charge accumulation, the model includes leakage:

- **`LEAKAGE_VALUE_A`** / **`LEAKAGE_VALUE_B`** — the rate of potential decay over time
- **`INHIBITION_VALUE_B`** — an inhibitory signal from neuron B that reduces the potential of neuron A (this provides mutual inhibition and stable rhythm generation)

---

### 3. Refractory Period

After firing a spike, the neuron enters a refractory state during which it cannot be excited.

The duration of this period is set by the parameters:
- `REFRACTORY_PERIOD_TIME_A`
- `REFRACTORY_PERIOD_TIME_B`

This is necessary to prevent excessively frequent spiking and ensures physiologically realistic behavior.

---

## 🧩 Interaction Between Neurons A and B

The two neurons (A and B) are connected in a cross-inhibitory manner:

- **A → B**: excitatory signal
- **B → A**: inhibitory signal (`INHIBITION_VALUE_B`)

This architecture creates **anti-phase rhythmic activity** — when A is active, B is inhibited, and vice versa. This is a classic CPG architecture that underlies many rhythmic movements.

---

