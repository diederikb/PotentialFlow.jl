module Source

import ..Points
import ..Blobs
import ..Elements: circulation, flux, kind, seed_position, seed_strength

import ..Utils: dualize, seed


#== Wrapper for a point source ==#

"""
    Source.Point(z::ComplexF64, S::Float64)

A point source located at `z` with strength `S`.

A new point source can be created from an existing one by treating the
existing source as a function and passing in the parameter you
want to change as keyword arguments.
For example,
```jldoctest
julia> p = Source.Point(1.0, 1.0)
Source.Point(1.0 + 0.0im, 1.0)

julia> p()
Source.Point(1.0 + 0.0im, 1.0)

julia> p(S = 2.0)
Source.Point(1.0 + 0.0im, 2.0)
```
"""
const Point = Points.Point{T,R} where {T<:Complex, R <: Real}
Point(z::Complex{R},S::T) where {T<:Real,R<:Real} = Points.Point{Complex{T}}(z,S)
Point(z::Real,S::T) where {T} = Points.Point{Complex{T}}(complex(z),S)

(p::Point)(; z = p.z, S = imag(p.S)) = Point(z, S)

function Base.show(io::IO, s::Point)
    if iszero(real(s.S))
        print(io, "Source.Point($(s.z), $(imag(s.S)))")
    else
        print(io, "Points.Point($(s.z), $(s.S))")
    end
end
flux(p::Point) = imag(p.S)
circulation(::Point) = 0.0

@inline dualize(::Type{T},v::Vector{<:Point}) where {T} =
        Point.(dualize.(T,Elements.position(v)),dualize.(T,flux.(v)))

@inline seed_position(::Type{T},v::Vector{<:Point},i::Int) where {T} =
        Point.(seed(T,Elements.position(v),i),flux.(v))

@inline seed_strength(::Type{T},v::Vector{<:Point},i::Int) where {T} =
        Point.(Elements.position(v),seed(T,flux.(v),i))


#== Wrapper for a blob source ==#

"""
    Source.Blob(z::ComplexF64, S::Float64, δ::Float64)

A regularized point source located at `z` with strength `S` and blob radius `δ`.

A new blob source can be created from an existing one by treating the
existing blob as a function and passing in the parameter you want to
change as keyword arguments.
For example,
```jldoctest
julia> b = Source.Blob(1.0, 1.0, 0.1)
Source.Blob(1.0 + 0.0im, 1.0, 0.1)

julia> b()
Source.Blob(1.0 + 0.0im, 1.0, 0.1)

julia> b(S = 2.0, δ = 0.01)
Source.Blob(1.0 + 0.0im, 2.0, 0.01)
```
"""
const Blob = Blobs.Blob{T,R} where {T<:Complex, R <: Real}
Blob(z::Complex{R},S::T,δ::Float64) where {T<:Real,R<:Real} = Blobs.Blob{Complex{T}}(z,S,δ)
Blob(z::Real,S::T,δ) where {T<:Real} = Blobs.Blob{Complex{T}}(complex(z),S,δ)


(b::Blob)(; z = b.z, S = imag(b.S), δ = b.δ) = Blob(z, S, δ)

function Base.show(io::IO, s::Blob)
    if iszero(real(s.S))
        print(io, "Source.Blob($(s.z), $(imag(s.S)), $(s.δ))")
    else
        print(io, "Blobs.Blob($(s.z), $(imag(s.S)), $(s.δ))")
    end
end
circulation(::Blob) = 0.0
flux(b::Blob) = imag(b.S)

@inline dualize(::Type{T},v::Vector{<:Blob}) where {T} =
        Blob.(dualize.(T,Elements.position(v)),dualize.(T,flux.(v)),Elements.blobradius(v))

@inline seed_position(::Type{T},v::Vector{<:Blob},i::Int) where {T} =
    Blob.(seed(T,Elements.position(v),i),flux.(v),Elements.blobradius(v))

@inline seed_strength(::Type{T},v::Vector{<:Blob},i::Int) where {T} =
    Blob.(Elements.position(v),seed(T,flux.(v),i),Elements.blobradius(v))


end
