/*
 * Copyright (C) 2018 Kestrel Institute (http://www.kestrel.edu)
 * License: A 3-clause BSD license. See the LICENSE file distributed with ACL2.
 * Author: Alessandro Coglio (coglio@kestrel.edu)
 */

package edu.kestrel.acl2.aij;

/**
 * Representation of ACL2 complex rationals.
 * These are the values that satisfy {@code complex-rationalp}.
 * Note that these values do not satisfy {@code rationalp}.
 * <p>
 * This class is not public because code outside this package
 * must use the public methods in the {@link Acl2Number} class
 * to create numbers (which may be rationals or complex rationals).
 */
final class Acl2ComplexRational extends Acl2Number {

    //////////////////////////////////////// private members:

    /**
     * Real part of the ACL2 complex rational.
     * This is never {@code null}.
     */
    private final Acl2Rational realPart;

    /**
     * Imaginary part of the ACL2 complex rational.
     * This is never {@code null} and never 0.
     */
    private final Acl2Rational imaginaryPart;

    /**
     * Constructs an ACL2 complex rational from its real and imaginary parts.
     */
    private Acl2ComplexRational(Acl2Rational realPart,
                                Acl2Rational imaginaryPart) {
        this.realPart = realPart;
        this.imaginaryPart = imaginaryPart;
    }

    //////////////////////////////////////// package-private members:

    /**
     * Returns {@code true},
     * consistently with the {@code complex-rationalp} ACL2 function.
     */
    @Override
    Acl2Symbol complexRationalp() {
        return Acl2Symbol.T;
    }

    //////////////////////////////////////// public members:

    /**
     * Checks if this ACL2 complex rational is equal to the argument object.
     * This is consistent with the {@code equal} ACL2 function.
     * If the argument is not a {@link Acl2Value}, the result is {@code false}.
     */
    @Override
    public boolean equals(Object o) {
        /* Two complex rationals are equal iff
           their real and imaginary parts are. */
        if (this == o) return true;
        if (!(o instanceof Acl2ComplexRational)) return false;
        Acl2ComplexRational that = (Acl2ComplexRational) o;
        if (!realPart.equals(that.realPart)) return false;
        return imaginaryPart.equals(that.imaginaryPart);
    }

    /**
     * Returns a hash code for this ACL2 complex rational.
     */
    @Override
    public int hashCode() {
        int result = realPart.hashCode();
        result = 31 * result + imaginaryPart.hashCode();
        return result;
    }

    /**
     * Returns a printable representation of this ACL2 complex rational.
     * We return a Java string that
     * conforms to ACL2's notation for complex rationals.
     */
    @Override
    public String toString() {
        return "#\\c(" + this.realPart + " " + this.imaginaryPart + ")";
    }

    /**
     * Returns an ACL2 complex rational with the given real and imaginary parts.
     * This method must be public because
     * the corresponding method in {@link Acl2Number} is public.
     * However, this method cannot be called from outside this package
     * because the {@link Acl2ComplexRational} class is not public.
     */
    public static Acl2ComplexRational make(Acl2Rational realPart,
                                           Acl2Rational imaginaryPart) {
        return new Acl2ComplexRational(realPart, imaginaryPart);
    }

    /**
     * Returns the real part of this ACL2 complex rational.
     */
    @Override
    public Acl2Rational getRealPart() {
        return this.realPart;
    }

    /**
     * Returns the imaginary part of this ACL2 complex rational.
     */
    @Override
    public Acl2Rational getImaginaryPart() {
        return this.imaginaryPart;
    }

}
